module Internal.Output.Foreign.TSDefaults where

import           Data.Text
import qualified Data.Text                             as T
import           Internal.Intermediate.Typescript.Lang
import           Internal.Output.Foreign.Class


{-
  DEFAULT FOREIGN INSTANCES
-}

instance (IsForeignType (TSCustom f), IsForeignType (TSComposite f))  => IsForeignType (TSType f) where
  toForeignType (TSPrimitiveType prim) = TSPrimitiveType <$> toForeignType prim
  toForeignType (TSCompositeType composite) = TSCompositeType <$> toForeignType composite
  toForeignType (TSCustomizableType tsCustom) = TSCustomizableType <$> toForeignType tsCustom


instance IsForeignType TSPrimitive where
  toForeignType TSString  = selfRefForeign "string"
  toForeignType TSNumber  = selfRefForeign "number"
  toForeignType TSBoolean = selfRefForeign "boolean"

instance (IsForeignType (TSType f)) => IsForeignType (TSInterface f) where
  toForeignType (TSInterface iName fields') =
    ForeignType
      {refName     = iName
      ,declaration =
          ("interface " <> iName <> " { \n"
          <> showFields fields'
          <> "\n}"
          )
      }


showField :: (IsForeignType (TSType f)) => TSField f -> Text
showField (TSField (FieldName fName) fType) = fName <> " : " <> (refName . toForeignType) fType

showFields ::  (IsForeignType (TSType f)) => [TSField f] -> Text
showFields fields = T.intercalate "\n" $ fmap (\f -> "  " <> showField f) fields

defaultForeignArray :: (IsForeignType (TSType f)) => TSArray f -> Text
defaultForeignArray (TSArray tsType') =
  "Array<" <> rep <> ">"
  where
    rep = refName . toForeignType $ tsType'
