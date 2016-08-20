package com.lzstudio.common.functions;

import java.io.InputStreamReader;
import java.io.LineNumberReader;
import java.net.NetworkInterface;
import java.util.Collections;
import java.util.List;

import com.lzstudio.common.ActivityBase;

import android.annotation.SuppressLint;
import android.content.Context;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.text.TextUtils;
import android.util.Log;

public class GetMacAddress {
	private static final String TAG = GetMacAddress.class.getSimpleName();
	private static String mac = null;
	private static String INVALID_MAC1 = "00:00:00:00:00:00";
	private static String INVALID_MAC2 = "02:00:00:00:00:00";


	public static String getMacAddress() {
		if (TextUtils.isEmpty(mac)) {
			mac = getMacFromDevice();
			Log.d(TAG, "getMacFromDevice mac:" + mac);
			if (TextUtils.isEmpty(mac) || INVALID_MAC1.equals(mac)|| INVALID_MAC2.equals(mac)) {
				mac = getMacFromNetwork();
				Log.d(TAG, "getMacFromNetwork mac:" + mac);
			}
			if (TextUtils.isEmpty(mac) || INVALID_MAC1.equals(mac)|| INVALID_MAC2.equals(mac)) {
				mac = getMacFromFile();
				Log.d(TAG, "getMacFromFile mac:" + mac);
			}
			if (INVALID_MAC1.equals(mac)|| INVALID_MAC2.equals(mac)) {
				mac = null;
			}
		}

		return mac;
	}

	// 尝试打开wifi
	private static boolean tryOpenMAC(WifiManager manager) {
		boolean softOpenWifi = false;
		int state = manager.getWifiState();
		if (state != WifiManager.WIFI_STATE_ENABLED
				&& state != WifiManager.WIFI_STATE_ENABLING) {
			manager.setWifiEnabled(true);
			softOpenWifi = true;
		}
		return softOpenWifi;
	}

	private static String tryGetMac(WifiManager manager) {
		WifiInfo info = manager.getConnectionInfo();
		if (info == null || TextUtils.isEmpty(info.getMacAddress())) {
			return null;
		}
		return info.getMacAddress();
	}

	private static String getMacFromDevice() {
		try {
			String mac = null;
			WifiManager wifiManager = (WifiManager) ActivityBase.getContext()
					.getSystemService(Context.WIFI_SERVICE);
			if (wifiManager != null) {
				WifiInfo wifiInfo = wifiManager.getConnectionInfo();
				if (wifiInfo != null) {
					mac = wifiInfo.getMacAddress();
					if (!TextUtils.isEmpty(mac) && !INVALID_MAC1.equals(mac) && !INVALID_MAC2.equals(mac)) {
						return mac;
					} else {
						boolean isOkWifi = tryOpenMAC(wifiManager);
						try {
							for (int index = 0; index < 3; index++) {// 尝试3次
								if (index != 0) {
									Thread.sleep(100);
								}

								mac = tryGetMac(wifiManager);
								if (!TextUtils.isEmpty(mac)) {
									return mac;
								}
							}
						} finally {
							if (isOkWifi) {
								wifiManager.setWifiEnabled(false);
							}
						}
					}
				}
			}
		} catch (Exception e) {
			Log.e(TAG, e.getMessage(), e);
		}

		return null;
	}

	@SuppressLint("NewApi")
	private static String getMacFromNetwork() {
		try {
			if (Build.VERSION.SDK_INT >= 9) {
				String interfaceName = "wlan0";
				List<NetworkInterface> interfaces = Collections
						.list(NetworkInterface.getNetworkInterfaces());
				for (NetworkInterface networkInterface : interfaces) {
					if (!networkInterface.getName().equalsIgnoreCase(
							interfaceName)) {
						continue;
					}
					byte[] mac = networkInterface.getHardwareAddress();
					if (mac == null) {
						return null;
					}
					StringBuilder buf = new StringBuilder();
					for (int idx = 0; idx < mac.length; idx++) {
						buf.append(String.format("%02X:", mac[idx]));
					}
					if (buf.length() > 0) {
						buf.deleteCharAt(buf.length() - 1);
					}
					return buf.toString();
				}
			}
		} catch (Exception e) {
			Log.e(TAG, e.getMessage(), e);
		}
		return null;
	}

	private static String getMacFromFile() {
		InputStreamReader ir = null;
		LineNumberReader input = null;
		Process pp = null;
		String mac;
		try {
			String str = "";
			pp = Runtime.getRuntime().exec("cat /sys/class/net/wlan0/address");
			ir = new InputStreamReader(pp.getInputStream());
			input = new LineNumberReader(ir);

			for (; str != null;) {
				str = input.readLine();
				if (str != null) {
					mac = str.trim();
					if (!TextUtils.isEmpty(mac)) {
						return mac;
					}
				}
			}
		} catch (Exception e) {
			Log.e(TAG, e.getMessage(), e);
		} finally {
			if (input != null) {
				try {
					input.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}

			if (ir != null) {
				try {
					ir.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}

			if (pp != null) {
				try {
					pp.destroy();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}
		return null;
	}
}
