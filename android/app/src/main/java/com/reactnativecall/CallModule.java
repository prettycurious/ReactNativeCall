package com.reactnativecall;

import android.util.Log;

import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

public class CallModule extends ReactContextBaseJavaModule {

    public CallModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "CallModule";
    }

    @ReactMethod
    public void add(String message) {
        // 删除保存的文件
        FileUtil.deletefile("StecAddress.txt");

        // 保存数据到txt文件中
        FileUtil.saveFile(message, "StecAddress.txt");// 保存为了一个txt文本
    }

    @ReactMethod
    public void delete() {
        // 删除保存的文件
        FileUtil.deletefile("StecAddress.txt");
    }
}
