package com.lzstudio.common.functions;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Matrix;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.Log;

import com.lzstudio.common.ActivityBase;
import com.lzstudio.common.ILifecycleObserver;

public class GetUserHead {
	private static final String TAG = "GetUserHead";
	private static final int PHOTO_REQUEST_TAKEPHOTO = 1;// 拍照
	private static final int PHOTO_REQUEST_GALLERY = 2;// 从相册中选择
	private static final int PHOTO_REQUEST_CUT = 3;// 结果
	
	public interface OnGetFilePathListener {
        public void onGetFilePath(String path);
    }
	
	private static OnGetFilePathListener getFiePathListener;
//	private static boolean isForBmob = false;
//	private static String bmobObjId = "";
	
	// 创建临时的文件
	private static File tempFile = new File(ActivityBase.getContext()
			.getFilesDir().getAbsolutePath(), "/temp.png");

	private static ILifecycleObserver ob = new ILifecycleObserver() {

		@Override
		public void onStop(Activity activity) {
			// TODO Auto-generated method stub

		}

		@Override
		public void onStart(Activity activity) {
			// TODO Auto-generated method stub

		}

		@Override
		public void onSaveInstanceState(Activity activity, Bundle outState) {
			// TODO Auto-generated method stub

		}

		@Override
		public void onResume(Activity activity) {
			// TODO Auto-generated method stub

		}

		@Override
		public void onRestoreInstanceState(Activity activity,
				Bundle savedInstanceState) {
			// TODO Auto-generated method stub

		}

		@Override
		public void onRestart(Activity activity) {
			// TODO Auto-generated method stub

		}

		@Override
		public void onPause(Activity activity) {
			// TODO Auto-generated method stub

		}

		@Override
		public void onDestroy(Activity activity) {
			// TODO Auto-generated method stub

		}

		@Override
		public void onCreate(Activity activity, Bundle savedInstanceState) {
			// TODO Auto-generated method stub

		}

		@Override
		public void onActivityResult(Activity activity, int requestCode,
				int resultCode, Intent data) {
			Log.d(TAG, "requestCode = " + requestCode);
			Log.d(TAG, "resultCode = " + resultCode);
			if (Activity.RESULT_CANCELED != resultCode) {
				switch (requestCode) {
				case PHOTO_REQUEST_TAKEPHOTO:
					startPhotoZoom(Uri.fromFile(tempFile), 1, 1, 100, 100);
					break;

				case PHOTO_REQUEST_GALLERY:
					if (data != null)
						startPhotoZoom(data.getData(), 1, 1, 100, 100);
					break;

				case PHOTO_REQUEST_CUT:
					if (data != null)
						savePic(data);
					break;
				}
			}
		}
	};

	private static void startPhotoZoom(Uri uri, int proportionx,
			int proportiony, int sizex, int sizey) {
		Intent intent = new Intent("com.android.camera.action.CROP");
		intent.setDataAndType(uri, "image/*");
		// crop为true是设置在开启的intent中设置显示的view可以剪裁
		intent.putExtra("crop", "true");

		// aspectX aspectY 是宽高的比例
		intent.putExtra("aspectX", proportionx);
		intent.putExtra("aspectY", proportiony);

		// outputX,outputY 是剪裁图片的宽高
		intent.putExtra("outputX", sizex);
		intent.putExtra("outputY", sizey);
		intent.putExtra("return-data", true);

		ActivityBase.getContext().startActivityForResult(intent,
				PHOTO_REQUEST_CUT);
	}

	// 将进行剪裁后的图片显示到UI界面上
	private static void savePic(Intent picdata) {
		Log.d(TAG, "savePic");
		Bundle bundle = picdata.getExtras();
		if (bundle != null) {
			Bitmap bm = bundle.getParcelable("data");

			// 缩放图片
			// 获得图片的宽高
			int width = bm.getWidth();
			int height = bm.getHeight();
			// 设置想要的大小
			int newWidth = 100;
			int newHeight = 100;
			// 计算缩放比例
			float scaleWidth = ((float) newWidth) / width;
			float scaleHeight = ((float) newHeight) / height;
			// 取得想要缩放的matrix参数
			Matrix matrix = new Matrix();
			matrix.postScale(scaleWidth, scaleHeight);
			// 得到新的图片
			Bitmap newbm = Bitmap.createBitmap(bm, 0, 0, width, height, matrix,
					true);

			// 保存到本地
			saveFile(newbm);
		}
	}

	private static void saveFile(Bitmap bitmap) {

		File p = new File(Environment.getExternalStorageDirectory()
				.getAbsolutePath()
				+ "/"
				+ ActivityBase.getContext().getPackageName());
		if (p != null && !p.exists()) {
			Log.i(TAG, "saveFile dir = " + p.toString());
			p.mkdirs();
		}
		
		String fileName = "userhead.jpg";
//		if (isForBmob){
//			fileName = bmobObjId+".jpg";
//		}
		
		File bitmapFile = new File(Environment.getExternalStorageDirectory()
				.getAbsolutePath()
				+ "/"
				+ ActivityBase.getContext().getPackageName(), "/"+fileName);

		try {
			if (bitmapFile.exists()) {
				bitmapFile.delete();
			}
			bitmapFile.createNewFile();
		} catch (IOException e) {
			e.printStackTrace();
		}

		FileOutputStream fos = null;
		try {
			fos = new FileOutputStream(bitmapFile);
			bitmap.compress(Bitmap.CompressFormat.JPEG, 40, fos);
//			if (!isForBmob) { 
				getUserHeadOnLua(bitmapFile.toString());
//			}else{
//				getFiePathListener.onGetFilePath(bitmapFile.toString());
//				isForBmob = false;
//			}
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} finally {
			try {
				if (null != fos) {
					fos.close();
				}
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
	
//	public static void getUserHeadForBmob(String objid,OnGetFilePathListener listener) {
//		getFiePathListener = listener;
//		bmobObjId = objid;
//		isForBmob = true;
//		ActivityBase.getContext().attach(ob);
//		Intent intent = new Intent(Intent.ACTION_PICK, null);
//		intent.setDataAndType(
//				MediaStore.Images.Media.EXTERNAL_CONTENT_URI, "image/*");
//		ActivityBase.getContext().startActivityForResult(intent,
//				PHOTO_REQUEST_GALLERY);
//		
//	}
	
	private static int callLuaGetUserHeadCallbackId = -1;
	
	// lua调用java
	public static void getUserHead(int luaFunctionId) {
		Log.d(TAG, "getUserHead luaFunctionId = " + luaFunctionId);
		if (callLuaGetUserHeadCallbackId != -1) {
			Cocos2dxLuaJavaBridge
					.releaseLuaFunction(callLuaGetUserHeadCallbackId);
			callLuaGetUserHeadCallbackId = -1;
		}
		callLuaGetUserHeadCallbackId = luaFunctionId;

		ActivityBase.getContext().runOnUiThread(new Runnable() {

			@Override
			public void run() {
				ActivityBase.getContext().attach(ob);
				Intent intent = new Intent(Intent.ACTION_PICK, null);
				intent.setDataAndType(
						MediaStore.Images.Media.EXTERNAL_CONTENT_URI, "image/*");
				ActivityBase.getContext().startActivityForResult(intent,
						PHOTO_REQUEST_GALLERY);
			}
		});

	}

	// java调用lua
	public static void getUserHeadOnLua(final String path) {
		Log.d(TAG, "getUserHeadOnLua path = " + path);
		ActivityBase.getContext().runOnGLThread(new Runnable() {
			
			@Override
			public void run() {
				Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callLuaGetUserHeadCallbackId, path);
			}
		});
	}

}
