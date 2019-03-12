package com.reactnativecall;

import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.telephony.PhoneStateListener;
import android.telephony.TelephonyManager;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.WindowManager;
import android.widget.TextView;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;

public class PhoneReceiver extends BroadcastReceiver {

    private Context mcontext;
    private WindowManager wm;

    @Override
    public void onReceive(Context context, Intent intent){
        mcontext=context;
        System.out.println("action"+intent.getAction());
        if(intent.getAction().equals(Intent.ACTION_NEW_OUTGOING_CALL)){
            //如果是去电（拨出）
            Log.d("TAG","拨出");
        }else{
            //查了下android文档，貌似没有专门用于接收来电的action,所以，非去电即来电
            Log.d("TAG","来电");
            TelephonyManager tm = (TelephonyManager)context.getSystemService(Service.TELEPHONY_SERVICE);
            tm.listen(listener, PhoneStateListener.LISTEN_CALL_STATE);
            //设置一个监听器
        }
    }

    private TextView tv;
    private LayoutInflater inflate;
    private View phoneView;
    private PhoneStateListener listener=new PhoneStateListener(){

        @Override
        public void onCallStateChanged(int state, final String incomingNumber) {

            // TODO Auto-generated method stub
            //state 当前状态 incomingNumber,貌似没有去电的API
            super.onCallStateChanged(state, incomingNumber);
            switch(state){
                case TelephonyManager.CALL_STATE_IDLE:
                    Log.d("TAG","挂断");
                    if (phoneView != null) {
                        wm.removeView(phoneView);
                        phoneView = null;
                    }
                    break;
                case TelephonyManager.CALL_STATE_OFFHOOK:
                    Log.d("TAG","接听");
                    if (phoneView != null) {
                        wm.removeView(phoneView);
                        phoneView = null;
                    }
                    break;
                case TelephonyManager.CALL_STATE_RINGING:


                    inflate= LayoutInflater.from(mcontext);
                    wm = (WindowManager)mcontext.getApplicationContext().getSystemService(Context.WINDOW_SERVICE);
                    WindowManager.LayoutParams params = new WindowManager.LayoutParams();
                    phoneView=inflate.inflate(R.layout.phone_alert,null);

//                    if (Build.VERSION.SDK_INT >= 26 && MyApplication.context.getApplicationInfo().targetSdkVersion > 22) {
//                        params.type = WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY;
//
//                    } else {
//                        PackageManager pm = context.getPackageManager();
//                        boolean permission = (PackageManager.PERMISSION_GRANTED == pm.checkPermission("android.permission.SYSTEM_ALERT_WINDOW", context.getPackageName()));
//                        if (permission || "Xiaomi".equals(Build.MANUFACTURER) || "vivo".equals(Build.MANUFACTURER)) {
//                            params.type = WindowManager.LayoutParams.TYPE_PHONE;
//                        } else {
//                            params.type = WindowManager.LayoutParams.TYPE_TOAST;
//                        }
//
//                    }

                    params.type = WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY;
//                    params.type = WindowManager.LayoutParams.TYPE_PHONE;
                    params.flags = WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL | WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE;

//                    params.flags = WindowManager.LayoutParams.FLAG_ALT_FOCUSABLE_IM
//                            | WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
//                            | WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
//                            | WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
//                            | WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
//                            | WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
//                            | WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL;

                    params.gravity= Gravity.CENTER;
//                    params.width = WindowManager.LayoutParams.MATCH_PARENT;
//                    params.height = 600;

                    params.width = WindowManager.LayoutParams.MATCH_PARENT;
                    params.height = WindowManager.LayoutParams.MATCH_PARENT;
                    params.format = PixelFormat.RGBA_8888;

                    // 读取保存的文件数据
                    String data = FileUtil.getFile("StecAddress.txt");
                    Log.d("TAG","响铃:来电号码"+data);

//                    // 删除保存的文件
//                    FileUtil.deletefile("save.txt");

                    if (data != null ) {
                        JSONArray array = JSON.parseArray(data);
                        for (int i = 0; i < array.size(); i++) {
                            //JSONArray中的数据转换为String类型需要在外边加"";不然会报出类型强转异常！
                            String str = array.get(i)+"";
                            JSONObject object = JSON.parseObject(str);
                            System.out.println(object.get("mobile"));

                            if (object.get("mobile").equals(incomingNumber)) {
                                tv = phoneView.findViewById(R.id.itemText);

                                tv.setText(object.get("company_emp_name").toString());

                                wm.addView(phoneView, params);
                            }
                        }
                    }

                    Log.d("TAG","响铃:来电号码"+incomingNumber);
                    Log.d("TAG","响铃:======"+ Thread.currentThread().getName());
                    //输出来电号码
                    break;
            }
        }
    };
};

