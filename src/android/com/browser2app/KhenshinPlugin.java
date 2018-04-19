package com.browser2app;

import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaArgs;
import com.browser2app.khenshin.Khenshin;
import com.browser2app.khenshin.KhenshinConstants;
import com.browser2app.khenshin.KhenshinApplication;
import com.browser2app.khenshin.domain.ApiCallBack;
import com.browser2app.khenshin.ISO8601;
import android.content.Intent;
import android.os.Bundle;
import android.app.Activity;
import java.util.UUID;
import java.util.Map;
import java.util.HashMap;
import com.browser2app.khenshin.LogWrapper;

import okhttp3.FormBody;
import okhttp3.HttpUrl;
import okhttp3.Interceptor;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;

import java.util.concurrent.TimeUnit;


import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;
import retrofit2.converter.scalars.ScalarsConverterFactory;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import com.browser2app.RipleyFittingInterface;

public class KhenshinPlugin extends CordovaPlugin {

	public RipleyFittingInterface ripleyApi;

	private String ripleyApiUrl = "https://khipu.com/ripley-fitting/api/";

	private static final String TAG = KhenshinPlugin.class.getSimpleName();

	private static final int START_PAYMENT_REQUEST_CODE = 101;

	CallbackContext currentCallbackContext;

	public KhenshinPlugin() {

		Gson gson = new GsonBuilder()
				.setDateFormat(KhenshinConstants.ISO8601_FORMAT)
				.create();

		OkHttpClient.Builder ripleyClientBuilder = new OkHttpClient.Builder()
				.connectTimeout(30, TimeUnit.SECONDS)
				.writeTimeout(30, TimeUnit.SECONDS)
				.readTimeout(30, TimeUnit.SECONDS);

		Retrofit ripleyRetrofit = new Retrofit.Builder()
				.baseUrl(ripleyApiUrl)
				.client(ripleyClientBuilder.build())
				.addConverterFactory(ScalarsConverterFactory.create())
				.addConverterFactory(ISO8601.ISO8601ConverterFactory.create())
				.addConverterFactory(GsonConverterFactory.create(gson))
				.build();

		ripleyApi = ripleyRetrofit.create(RipleyFittingInterface.class);

	}

	public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
		CordovaArgs cordovaArgs = new CordovaArgs(args);
		currentCallbackContext = callbackContext;
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
		} else if ("createPayment".equals(action)) {
			Map<String, String> params = new HashMap();
			for(int i = 0; i < args.length(); i++) {
				String[] kv = cordovaArgs.getString(i).split(":");
				params.put(kv[0], kv[1]);
			}
			createPayment(params);
			return true;
		}
		return false;
	}

	void createPayment(Map<String, String> map) {
		ripleyApi.paymentCreate(
				map.get("account_number")
				, map.get("personal_identifier")
				, map.get("alias")
				, map.get("account_name")
				, map.get("subject")
				, map.get("amount")
				, map.get("developer")).enqueue(new Callback<PaymentCreateResponse>() {

			@Override
			public void onResponse(Call<PaymentCreateResponse> call, Response<PaymentCreateResponse> response){
				PaymentCreateResponse paymentCreateResponse = response.body();
				startByPaymentId(paymentCreateResponse.getPaymentId());
			}

			@Override
			public void onFailure(Call<PaymentCreateResponse> call, Throwable t){

			}
		});
	}


	void startByPaymentId(String paymentId) {
		Intent intent = ((KhenshinApplication)cordova.getActivity().getApplicationContext()).getKhenshin().getStartTaskIntent();
		intent.putExtra(KhenshinConstants.EXTRA_PAYMENT_ID, paymentId);
		intent.putExtra(KhenshinConstants.EXTRA_FORCE_UPDATE_PAYMENT, false);
		intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
		cordova.setActivityResultCallback(this);
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

		intent.putExtra(KhenshinConstants.EXTRA_AUTOMATON_PARAMETERS, params);
		intent.putExtra(KhenshinConstants.EXTRA_FORCE_UPDATE_PAYMENT, false);
		intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
		cordova.setActivityResultCallback(this);
		cordova.getActivity().startActivityForResult(intent, START_PAYMENT_REQUEST_CODE);

	}

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent intent) {
		if(requestCode == START_PAYMENT_REQUEST_CODE){
			if(resultCode == Activity.RESULT_OK){
				currentCallbackContext.success("OK");
			} else {
				currentCallbackContext.error("ERROR");
			}
		}
	}
}