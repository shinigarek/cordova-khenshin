package com.browser2app;

import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaArgs;
import com.browser2app.khenshin.KhenshinConstants;
import com.browser2app.khenshin.KhenshinApplication;
import android.content.Intent;
import android.os.Bundle;
import java.util.UUID;
import java.util.Map;
import java.util.HashMap;

public class KhenshinPlugin extends CordovaPlugin {

	private static final int START_PAYMENT_REQUEST_CODE = 101;

	public KhenshinPlugin() {

	}

	public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
		CordovaArgs cordovaArgs = new CordovaArgs(args);
		if("startByPaymentId".equals(action)) {
			startByPaymentId(cordovaArgs.getString(0));
			return true;
		} else if ("startByAutomatonId".equals(action)) {
			Map<String, String> params = new HashMap();
			for(int i = 1; i < args.length(); i++) {
				String[] kv = cordovaArgs.getString(i).split(":");
				params.put(kv[0], kv[1]);
			}
			startByAutomatonId(cordovaArgs.getString(0), params);
			return true;
		}
		return false;
	}


	void startByPaymentId(String paymentId) {
		Intent intent = ((KhenshinApplication)cordova.getActivity().getApplicationContext()).getKhenshin().getStartTaskIntent();
		intent.putExtra(KhenshinConstants.EXTRA_PAYMENT_ID, paymentId);
		intent.putExtra(KhenshinConstants.EXTRA_FORCE_UPDATE_PAYMENT, false);
		intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
		cordova.getActivity().startActivityForResult(intent, START_PAYMENT_REQUEST_CODE);
	}

	void startByAutomatonId(String automatonId, Map<String, String> map) {
		Intent intent = ((KhenshinApplication)cordova.getActivity().getApplicationContext()).getKhenshin().getStartTaskIntent();
		intent.putExtra(KhenshinConstants.EXTRA_AUTOMATON_ID, automatonId);
		Bundle params = new Bundle();

		for (Map.Entry<String, String> entry : map.entrySet())
		{
			params.putString(entry.getKey(), entry.getValue());
		}

		/*
		params.putString("subject", "Pago prueba");
		params.putString("amount", "2000");
		params.putString("merchant", "Comercio de prueba");
		params.putString("paymentId", UUID.randomUUID().toString());
		params.putString("khipu_account_name", "PAGOCMR");
		params.putString("khipu_account_number", "55200104571");
		params.putString("khipu_alias", "PAGOCMR");
		params.putString("payer_name", "Emilio Davis");
		params.putString("payer_email", "cmr@khipu.com");
		params.putString("khipu_rut", "10.706.077-4");
		params.putString("khipu_email", "transferencias@khipu.com");
		*/

		intent.putExtra(KhenshinConstants.EXTRA_AUTOMATON_PARAMETERS, params);
		intent.putExtra(KhenshinConstants.EXTRA_FORCE_UPDATE_PAYMENT, false);
		intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
		cordova.getActivity().startActivityForResult(intent, START_PAYMENT_REQUEST_CODE);
	}
}