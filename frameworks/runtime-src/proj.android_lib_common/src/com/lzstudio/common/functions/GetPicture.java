package com.lzstudio.common.functions;

import android.app.Activity;
import android.content.ContentResolver;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.Log;

import com.lzstudio.common.ActivityBase;
import com.lzstudio.common.ILifecycleObserver;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

public class GetPicture {
	private static final String TAG = "GetPicture";
	private static final int PHOTO_REQUEST_GALLERY = 2;// 从相册中选择

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
                    case PHOTO_REQUEST_GALLERY:
                        if (data != null) {
                        Uri uri = data.getData();
                        ContentResolver cr = activity.getContentResolver();
                        try {
                            Bitmap bm = BitmapFactory.decodeStream(cr.openInputStream(uri));

                            // 缩放图片
                            // 获得图片的宽高
                            int width = bm.getWidth();
                            int height = bm.getHeight();
                            // 设置想要的大小
                            int newWidth = 680;
                            int newHeight = 500;
                            // 计算缩放比例
                            float scaleWidth = ((float) newWidth) / width;
                            float scaleHeight = ((float) newHeight) / height;
                            // 取得想要缩放的matrix参数
                            Matrix matrix = new Matrix();
                            matrix.postScale(scaleWidth, scaleHeight);
                            // 得到新的图片
                            Bitmap newbm = Bitmap.createBitmap(bm, 0, 0, width, height, matrix,
                                    true);
                            saveFile(newbm);
                        } catch (FileNotFoundException e) {
                            Log.e("Exception", e.getMessage(),e);
                        }
                    }
					break;
				}
			}
		}
	};

	private static void saveFile(Bitmap bitmap) {
        Log.d(TAG, "saveFile");
		File p = new File(Environment.getExternalStorageDirectory()
				.getAbsolutePath()
				+ "/"
				+ ActivityBase.getContext().getPackageName());
		if (p != null && !p.exists()) {
			Log.i(TAG, "saveFile dir = " + p.toString());
			p.mkdirs();
		}

		File bitmapFile = new File(Environment.getExternalStorageDirectory()
				.getAbsolutePath()
				+ "/"
				+ ActivityBase.getContext().getPackageName(), "/feedback.jpg");

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
			getPictureOnLua(bitmapFile.toString());
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

	private static int callLuaGetPictureCallbackId = -1;

	// lua调用java
	public static void getPicture(int luaFunctionId) {
		Log.d(TAG, "getPicture luaFunctionId = " + luaFunctionId);
		if (callLuaGetPictureCallbackId != -1) {
			Cocos2dxLuaJavaBridge
					.releaseLuaFunction(callLuaGetPictureCallbackId);
			callLuaGetPictureCallbackId = -1;
		}
		callLuaGetPictureCallbackId = luaFunctionId;

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
	public static void getPictureOnLua(final String path) {
		Log.d(TAG, "getPictureOnLua path = " + path);
		ActivityBase.getContext().runOnGLThread(new Runnable() {
			
			@Override
			public void run() {
				Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callLuaGetPictureCallbackId, path);
			}
		});
	}

}
