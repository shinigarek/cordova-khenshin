package com.browser2app;

import android.app.Application;
import android.os.Build;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.browser2app.khenshin.Khenshin;
import com.browser2app.khenshin.KhenshinInterface;
import com.browser2app.khenshin.KhenshinApplication;
import com.browser2app.khenshin.automaton.WebClient;

public class CordovaKhenshinApplication extends Application implements KhenshinApplication{

	private Khenshin khenshin;

	@Override
	public KhenshinInterface getKhenshin() {
		return khenshin;
	}

	public CordovaKhenshinApplication() {

		khenshin = new Khenshin.KhenshinBuilder()
				.setApplication(this)
				.setTaskAPIUrl("https://khipu.com/app/2.0/")
				.setDumpAPIUrl("https://khipu.com/cerebro/")
				.setMainButtonStyle(Khenshin.CONTINUE_BUTTON_IN_FORM)
				.setAllowCredentialsSaving(true)
				.setHideWebAddressInformationInForm(false)
				.setAutomatonTimeout(90)
				.setSkipExitPage(false)
				.build();
	}


}
