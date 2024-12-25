import { useEffect, useState } from 'react';
import { Text, View, StyleSheet, Button } from 'react-native';
import {
  setIcon,
  getAllAlternativeIcons,
  resetIcon,
  getActiveIcon,
} from 'react-native-app-icon-changer';

export default function App() {
  const [icons, setIcons] = useState<[] | string[]>([]);

  const changeIconHandler = async (iconName: string) => {
    try {
      const response = await setIcon(iconName);
      console.log('Success', response);
    } catch (error) {
      console.log('Error', JSON.stringify(error));
    }
  };

  const getActiveIconHandler = async () => {
    try {
      const currentIcon = await getActiveIcon();
      console.log('Active Icon', currentIcon);
    } catch (error) {
      console.log('Error', JSON.stringify(error));
    }
  };

  const resetIconHandler = async () => {
    try {
      const response = await resetIcon();
      console.log('Success', response);
    } catch (error) {
      console.log('Error', JSON.stringify(error));
    }
  };

  useEffect(() => {
    (async () => {
      const icons = await getAllAlternativeIcons();
      setIcons(icons);
    })();
  }, []);

  return (
    <View style={styles.container}>
      <Text>
        Icons:{icons.join(', ')}
        {icons.map((icon) => {
          return (
            <Button
              key={icon}
              title={icon}
              onPress={changeIconHandler.bind(null, icon)}
            />
          );
        })}
        <Button title={'Reset'} onPress={resetIconHandler} />
        <Button title={'Active Icon'} onPress={getActiveIconHandler} />
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
