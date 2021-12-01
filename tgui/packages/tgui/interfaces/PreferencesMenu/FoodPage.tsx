import { useBackend } from "../../backend";
import { ServerPreferencesFetcher } from "./ServerPreferencesFetcher";
import { createSetPreference, Food, PreferencesMenuData, ServerData, ServerSpeciesData } from "./data";

const FOOD_ICONS = {
  [Food.Cloth]: "tshirt",
  [Food.Dairy]: "cheese",
  [Food.Fried]: "bacon",
  [Food.Fruit]: "apple-alt",
  [Food.Grain]: "bread-slice",
  [Food.Gross]: "trash",
  [Food.Junkfood]: "pizza-slice",
  [Food.Meat]: "hamburger",
  [Food.Nuts]: "acorn",
  [Food.Raw]: "drumstick-bite",
  [Food.Seafood]: "fish",
  [Food.Sugar]: "candy-cane",
  [Food.Toxic]: "biohazard",
  [Food.Vegetables]: "carrot",
};

const FOOD_NAMES: Record<keyof typeof FOOD_ICONS, string> = {
  [Food.Cloth]: "Clothing",
  [Food.Dairy]: "Dairy",
  [Food.Fried]: "Fried food",
  [Food.Fruit]: "Fruit",
  [Food.Grain]: "Grain",
  [Food.Gross]: "Gross food",
  [Food.Junkfood]: "Junk food",
  [Food.Meat]: "Meat",
  [Food.Nuts]: "Nuts",
  [Food.Raw]: "Raw",
  [Food.Seafood]: "Seafood",
  [Food.Sugar]: "Sugar",
  [Food.Toxic]: "Toxic food",
  [Food.Vegetables]: "Vegetables",
};

const FoodList = (props: {
  food: Food[],
  icon: string,
  name: string,
  className: string,
}) => {
  if (props.food.length === 0) {
    return null;
  }

export const FoodPage = (props : {
  closeFood: () => void
}) => {
  return (
