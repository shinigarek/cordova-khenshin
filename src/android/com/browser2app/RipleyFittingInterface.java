package com.browser2app;

import com.browser2app.khenshin.domain.ApiReponse;

import retrofit2.Call;
import retrofit2.http.Field;
import retrofit2.http.FormUrlEncoded;
import retrofit2.http.POST;
import retrofit2.http.Path;

public interface RipleyFittingInterface {

	@FormUrlEncoded
	@POST("payment/create")
	Call<PaymentCreateResponse> paymentCreate(
			@Field("account_number") String accountNumber
			, @Field("personal_identifier") String personalIdentifier
			, @Field("alias") String alias
			, @Field("account_name") String accountName
			, @Field("subject") String subject
			, @Field("amount") String amount
			, @Field("developer") String developer);
}
