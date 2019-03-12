/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 * @lint-ignore-every XPLATJSCOPYRIGHT1
 */

import React, {Component} from 'react';
import {Platform, StyleSheet, Text, View, NativeModules, Button, TextInput} from 'react-native';

import MapView from './MapView';

import ToastExample from "./ToastExample";
import CallModule from "./CallModule"

const instructions = Platform.select({
    ios: 'Press Cmd+R to reload,\n' + 'Cmd+D or shake for dev menu',
    android:
        'Double tap R on your keyboard to reload,\n' +
        'Shake or press menu button for dev menu',
});

const array = [
    {"8613818791880": "城建信息-陈楠"},
    {"8615690723502": "诈骗电话"},
    {"8615690723503": "骚扰电话"},
    {"8615690723504": "诈骗电话"},
    {"8615690723505": "广告推销"},
    {"8615690723506": "诈骗电话"},
    {"8615690723507": "广告推销"},
    {"8615690723508": "广告推销"},
    {"8615690723601": "城建信息-田文渊"},
];

type Props = {};
export default class App extends Component<Props> {

    constructor(props) {
        super(props);
        this.state = {
            label: '信息科技-田文渊',
            phone: '8615690723601'
        }
    }

    onRegionChange(event) {
        // Do stuff with event.region.latitude, etc.
        console.log(event);
    }

    componentDidMount() {
        if(Platform.OS === 'ios') {
            this.add();
            setTimeout(() => {
                const CallDirectoryManager = NativeModules.CallDirectoryManager;
                CallDirectoryManager.addInfo(this.state.phone, {
                    label: this.state.label
                });
            }, 1000*60)
        }
    }

    add = () => {
        let date = new Date();
        const CallDirectoryManager = NativeModules.CallDirectoryManager;
        // for (int i = 0; i < 1500000; i++) {
        //     NSString *name = @"测试时";
        //     NSString *phone = [NSString stringWithFormat:@"%ld", (18000000000 + i)];
        //     [self.manager addPhoneNumber:phone label:name];
        //     name = nil;
        //     phone = nil;
        // }

        for (let i in array) {

            console.log(array[i])
            console.log(Object.values(array[i]))
            console.log(Object.keys(array[i]))
            // for (let index in array[i]) {
            //
            //     console.log('key=', index, 'value=', array[index])
            //
            // }

            CallDirectoryManager.addPhone(Object.keys(array[i]).toString(), {
                label: Object.values(array[i]).toString()
            });

        }
    };

    addAndroid = () => {
        console.warn("add");
        ToastExample.show("Awesome", ToastExample.SHORT);
        CallModule.add("[{'mobile':'6505551212','company_emp_name':'城建设计总院-张春英'},{'mobile':'8613002108515','company_emp_name':'城市运营-连丽'}]")
    };

    deleteAndroid = () => {
        console.warn("delete");
        CallModule.delete()
    };

    deleteIos = () => {
        console.warn("delete");
    };

    render() {
        return (
            <View style={styles.container}>
                <View style={styles.itemView}>
                    <Text>手机号码</Text>
                    <TextInput></TextInput>
                </View>
                <View style={styles.itemView}>
                    <Text>标签</Text>
                    <TextInput></TextInput>
                </View>
                <Button title="add" onPress={Platform.OS === 'ios' ? this.add : this.addAndroid}/>
                <Button title="delete" onPress={Platform.OS === 'ios' ? this.deleteIos : this.deleteAndroid}/>
            </View>
        );
    }

    // render() {
    //   var region = {
    //     latitude: 37.48,
    //     longitude: -122.16,
    //     latitudeDelta: 0.1,
    //     longitudeDelta: 0.1,
    //   };
    //   return (
    //       <MapView
    //           region={region}
    //           zoomEnabled={false}
    //           style={{ flex: 1 }}
    //           onRegionChange={this.onRegionChange}
    //       />
    //   );
    // }

}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: '#F5FCFF',
    },
    itemView: {
        flexDirection: 'row',
        justifyContent: 'center',
        alignItems: 'center',
        marginBottom: 10
    },
    welcome: {
        fontSize: 20,
        textAlign: 'center',
        margin: 10,
    },
    instructions: {
        textAlign: 'center',
        color: '#333333',
        marginBottom: 5,
    },
});
