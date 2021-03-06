module Test.Main where

import Debug.Trace
import Data.Either
import Data.Maybe
import Test.QuickCheck
import Data.ArrayBuffer.Types
import qualified Data.ArrayBuffer.ArrayBuffer as AB
import qualified Data.ArrayBuffer.DataView as DV
import qualified Data.ArrayBuffer.Typed as TA
import Data.ArrayBuffer.Show
import Control.Monad.Eff
import Control.Monad.Eff.Random
import Control.Monad.Eff.Exception
import Math

main :: Eff (trace :: Trace, random :: Random, err :: Exception, writer :: DV.Writer, reader :: DV.Reader) Unit
main = do
  let ab = AB.create 4
  assert $ AB.byteLength ab == 4
  assert $ AB.byteLength (AB.slice 0 2 ab) == 2
  assert $ AB.byteLength (AB.slice 2 4 ab) == 2
  assert $ AB.byteLength (AB.slice (-2) (-2) ab) == 0
  assert $ AB.byteLength (AB.slice (-2) (-1) ab) == 1     
  assert $ (DV.byteLength <$> (DV.slice 0 2 ab)) == Just 2
  assert $ (DV.byteLength <$> (DV.slice 2 2 ab)) == Just 2
  let aab = AB.fromArray [1, 2, 3, 4]
  assert $ AB.byteLength aab == 4
  let sab = AB.fromString "hola"
  assert $ AB.byteLength sab == 8

  let nab = AB.create 8
  let dv = DV.whole nab      
  assert $ AB.byteLength (DV.buffer dv) == 8

  assert $ AB.byteLength (DV.buffer $ TA.dataView (TA.asInt8Array dv)) == 8

  assert $ (DV.byteLength <$> DV.slice 0 4 nab) == Just 4
  assert $ (DV.byteLength <$> DV.slice 0 40 nab) == Nothing

  assert $ do
     let ab = AB.fromArray [1,2,3,4]
     let dv = DV.whole ab
     let i8 = TA.asInt8Array dv
     ((Just 2) == i8 `TA.at` 1) && (Nothing == i8 `TA.at` 4) && (Nothing == i8 `TA.at` (-1))

  assert $ [1,2,3] == (TA.toArray $ TA.asInt8Array $ DV.whole $ AB.fromArray [1,2,3])


assert :: Boolean -> QC Unit
assert = quickCheck' 1

