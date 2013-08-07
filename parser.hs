import Text.ParserCombinators.Parsec hiding (spaces)
import System.Environment
import Control.Monad

data LispVal = Atom String
             | List [LispVal]
             | DottedList [LispVal] LispVal
             | Number Integer
             | String String
             | Bool Bool

main :: IO ()
main = do 
    args <- getArgs
    putStrLn (readExpr (args !! 0))

spaces :: Parser ()
spaces = skipMany1 space

symbol :: Parser Char
symbol = oneOf "!#$%&|*+-/:<=>?@^_~"

readExpr :: String -> String
readExpr input = case parse parseExpr "lisp" input of
    Left err -> "No match: " ++ show err
    Right val -> "Found value"

parseString :: Parser LispVal
parseString = do
                char '"'
                x <- many parseEscaped
                char '"'
                return $ String x

parseEscaped :: Parser Char
parseEscaped = (char '\\' >> (oneOf "nrt\\\""))
               <|> noneOf "\""
-- parseEscaped = let c =  string "\\n" 
--                     <|> string "\\\"" 
--                     <|> string "\\r" 
--                     <|> string "\\t" 
--                     <|> string "\\" 
--                     <|> (liftM show $ noneOf "\"")
--                in liftM head $ c          
            

parseAtom :: Parser LispVal
parseAtom = do 
                first <- letter <|> symbol
                rest <- many (letter <|> digit <|> symbol)
                let atom = first:rest
                return $ case atom of
                            "#t" -> Bool True
                            "#f" -> Bool False
                            _    -> Atom atom

parseNumber :: Parser LispVal
parseNumber = do
                d <- many1 digit
                    -- <|> readHex
                    -- <|> many1 digit
                return $ (Number . read) d

parseExpr :: Parser LispVal
parseExpr = parseAtom
        <|> parseString
        <|> parseNumber
