{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Risk where

import Control.Applicative
import Control.Monad.Random
import Control.Monad
import Data.List (sort)

------------------------------------------------------------
-- Die values

newtype DieValue = DV { unDV :: Int }
  deriving (Eq, Ord, Show, Num)

first :: (a -> b) -> (a, c) -> (b, c)
first f (a, c) = (f a, c)

instance Random DieValue where
  random           = first DV . randomR (1,6)
  randomR (low,hi) = first DV . randomR (max 1 (unDV low), min 6 (unDV hi))

die :: Rand StdGen DieValue
die = getRandom

dice :: Int -> Rand StdGen [DieValue]
dice n = replicateM n die

------------------------------------------------------------
-- Risk

type Army = Int

data Battlefield = Battlefield { attackers :: Army, defenders :: Army }
  deriving Show

exactSuccessProb :: Battlefield -> Double
exactSuccessProb bf = 0

-- | Runs 1000 invades and uses the results to compute a @Double@ between 0 and
-- 1 representing the estimated probability that the attacking army will
-- completely destroy the defending army.
succesProb :: Battlefield -> Rand StdGen Double
succesProb bf = replicateM 1000 (invade bf) >>= success

success :: [Battlefield] -> Rand StdGen Double
success bfs = return $ fromIntegral (length x)  / fromIntegral (length bfs)
  where x = filter ((== 0) . defenders) bfs

