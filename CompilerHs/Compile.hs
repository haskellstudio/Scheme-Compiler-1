module CompilerHs.Compile
  ( p423Compile
  ) where

import System.IO
import System.Cmd
import System.Process
import System.Exit
import Control.Exception (throw)

import FrameworkHs.Driver
import FrameworkHs.Prims
import FrameworkHs.Helpers
import FrameworkHs.SExpReader.LispData

import FrameworkHs.ParseL01                    (parseProg)
import FrameworkHs.GenGrammars.L01VerifyScheme
import CompilerHs.VerifyScheme                 (verifyScheme)
import CompilerHs.GenerateX86_64               (generateX86_64)

import qualified Data.ByteString as B

assemblyCmd :: String
assemblyCmd = "cc"
assemblyArgs :: [String]
assemblyArgs = ["-m64","-o","t","t.s","Framework/runtime.c"]

vfs = P423Pass { pass = verifyScheme
               , passName = "verifyScheme"
               , wrapperName = "verify-scheme/wrapper"
               , trace = False
               }

p423Compile :: P423Config -> LispVal -> IO String
p423Compile c l = do
  let p1 = runPassM c $ parseProg l
  p <- runPass vfs c p1
  assemble c $ generateX86_64 p

------------------------------------------------------------
-- Helpers -------------------------------------------------

assemble :: P423Config -> Gen -> IO String
assemble c out =
  case runGenM c out of
    Left err -> error err
    Right (_,bsout) -> do  
      B.writeFile "t.s" bsout
      (ec,_,e) <- readProcessWithExitCode assemblyCmd assemblyArgs ""
      case ec of
        ExitSuccess   -> do res <- readProcess "./t" [] ""
                            return (chomp res)
        ExitFailure i -> throw (AssemblyFailedException e)