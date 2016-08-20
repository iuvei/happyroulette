package com.lzstudio.common;

import org.cocos2dx.lib.Cocos2dxActivity;

import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.content.pm.PackageInfo;
import android.os.Bundle;
import android.view.WindowManager;

public abstract class ActivityBase extends Cocos2dxActivity {
	public static final String ACTION_ADD_SHORTCUT = "com.android.launcher.action.INSTALL_SHORTCUT";
	public static final String ACTION_REMOVE_SHORTCUT = "com.android.launcher.action.UNINSTALL_SHORTCUT";
	public static final String INSTALL_VERSION_NAME = "INSTALL_SHORTCUT_VERSION_NAME";
	public static final String LAST_VERSION_NAME = "LAST_INSTALL_SHORTCUT_VERSION_NAME";
	
	protected abstract void setComponents();
	
	protected ComponentManager componManager = new ComponentManager();
	protected LifecycleHelper lifecycleHelper = new LifecycleHelper();

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);		
		setComponents();
		componManager.init();
		lifecycleHelper.onCreate(this, savedInstanceState);
		
		getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
	}

	@Override
	protected void onResume() {
		super.onResume();
		lifecycleHelper.onResume(this);
	}

	@Override
	protected void onPause() {
		super.onPause();
		lifecycleHelper.onPause(this);
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		lifecycleHelper.onDestroy(this);
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		lifecycleHelper.onActivityResult(this, requestCode, resultCode, data);
	}

	@Override
	protected void onRestoreInstanceState(Bundle savedInstanceState) {
		super.onRestoreInstanceState(savedInstanceState);
		lifecycleHelper.onRestoreInstanceState(this, savedInstanceState);
	}

	@Override
	protected void onStart() {
		super.onStart();
		lifecycleHelper.onStart(this);
	}

	@Override
	protected void onRestart() {
		super.onRestart();
		lifecycleHelper.onRestart(this);
	}

	@Override
	protected void onSaveInstanceState(Bundle outState) {
		super.onSaveInstanceState(outState);
		lifecycleHelper.onSaveInstanceState(this, outState);
	}

	@Override
	protected void onStop() {
		super.onStop();
		lifecycleHelper.onStop(this);
	}

	public ComponentManager getComponentManager(){
		return componManager;
	}
	
	public void attach(ILifecycleObserver observer) {
		lifecycleHelper.attach(observer);
	}

	public void detach(ILifecycleObserver observer){
		lifecycleHelper.detach(observer);
	}
	
	public static ActivityBase getContext(){
		return (ActivityBase) Cocos2dxActivity.getContext();
	}
	
	public void createShortcut(int nameId, int iconId){
		try {
			SharedPreferences sharedPreferences = getSharedPreferences(INSTALL_VERSION_NAME, MODE_PRIVATE);
			String lastVersion = sharedPreferences.getString(LAST_VERSION_NAME, null);
		    PackageInfo packInfo = getPackageManager().getPackageInfo(getPackageName(), 0);
		    String installVersion = packInfo.versionName;
		    if(lastVersion == null || !lastVersion.equals(installVersion)) {
		    	delShortcut(nameId);
				addShortcut(nameId, iconId);
				Editor editor = sharedPreferences.edit();
				editor.putString(LAST_VERSION_NAME, installVersion);
				editor.commit();
			}
		} catch (Exception e) {
			e.printStackTrace();
		}		
	}
	
    private void addShortcut(int nameId, int iconId) {
    	try{
            Intent addShortcutIntent = new Intent(ACTION_ADD_SHORTCUT);

            // 不允许重复创建
            addShortcutIntent.putExtra("duplicate", false);// 经测试不是根据快捷方式的名字判断重复的
            // 应该是根据快链的Intent来判断是否重复的,即Intent.EXTRA_SHORTCUT_INTENT字段的value
            // 但是名称不同时，虽然有的手机系统会显示Toast提示重复，仍然会建立快链
            // 屏幕上没有空间时会提示
            // 注意：重复创建的行为MIUI和三星手机上不太一样，小米上似乎不能重复创建快捷方式

            // 名字
            addShortcutIntent.putExtra(Intent.EXTRA_SHORTCUT_NAME, getString(nameId));

            // 图标
            addShortcutIntent.putExtra(Intent.EXTRA_SHORTCUT_ICON_RESOURCE,
                    Intent.ShortcutIconResource.fromContext(getApplicationContext(), iconId));

            // 设置关联程序
            Intent launcherIntent = getPackageManager().getLaunchIntentForPackage(getPackageName());

            addShortcutIntent.putExtra(Intent.EXTRA_SHORTCUT_INTENT, launcherIntent);

            // 发送广播
            sendBroadcast(addShortcutIntent);    		
    	}catch(Exception e){
    		e.printStackTrace();
    	}
    }	
    
    private void delShortcut(int nameId) {
    	try{
            // del shortcut的方法在小米系统上不管用，在三星上可以移除
            Intent intent = new Intent(ACTION_REMOVE_SHORTCUT);

            // 名字
            intent.putExtra(Intent.EXTRA_SHORTCUT_NAME, getString(nameId));

            // 设置关联程序
            Intent launcherIntent = getPackageManager().getLaunchIntentForPackage(getPackageName());

            intent.putExtra(Intent.EXTRA_SHORTCUT_INTENT, launcherIntent);

            // 发送广播
            sendBroadcast(intent);    		
    	}catch(Exception e){
    		e.printStackTrace();
    	}
    }    
}
