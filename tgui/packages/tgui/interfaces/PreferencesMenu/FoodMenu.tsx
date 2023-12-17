export const FoodPage = (props) => {
  const { data } = useBackend<PreferencesMenuData>();
  return (
    <Stack>
      <Stack.Item>
        <Section title="Food Preferences" />
      </Stack.Item>
    </Stack>
  );
};
