class ApiConstants {
  // Manual environment switch:
  // Keep only one URL uncommented at a time when you want to switch manually.
  // For Android emulator localhost, use http://10.0.2.2:4000/
  // For iOS simulator localhost, use http://localhost:4000/
  static const String _selectedBaseUrl = "https://api.hungzo.in/";
  // static const String _selectedBaseUrl = "https://hungzo-backend.onrender.com/";
  // static const String _selectedBaseUrl = "http://10.66.210.138:4000/"; //testing localhost

  static final String baseURL = _withTrailingSlash(
    const String.fromEnvironment(
      "API_BASE_URL",
      defaultValue: _selectedBaseUrl,
    ),
  );

  static final String socketBaseUrl = _socketBaseUrl(
    const String.fromEnvironment("SOCKET_BASE_URL", defaultValue: ""),
    baseURL,
  );

  static final String imageURL = _withTrailingSlash(
    const String.fromEnvironment(
      "IMAGE_BASE_URL",
      defaultValue: _selectedBaseUrl,
    ),
  );

  static final String razorpayLogoUrl =
      "${baseURL}assets/logo/razorpay-hungzo-logo.jpeg";
  
  static String _withTrailingSlash(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      return trimmed;
    }
    return trimmed.endsWith("/") ? trimmed : "$trimmed/";
  }

  static String _socketBaseUrl(String configuredValue, String restBaseUrl) {
    final trimmed = configuredValue.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }

    final normalizedRest = restBaseUrl.replaceFirst(RegExp(r"/+$"), "");
    if (normalizedRest.startsWith("https://")) {
      return "$normalizedRest/drivers";
    }

    return "${normalizedRest.replaceFirst("http://", "ws://")}/drivers";
  }

  // Api endpoints
  static const accessTokenNew = 'auth/refresh';
  static const authLogout = 'auth/logout';
  static const authRequestDriverPhoneOtp = 'auth/driver/phone-otp/request';
  static const authVerifyDriverPhoneOtp = 'auth/driver/phone-otp/verify';
  static const userLogin = "user/login";
  static const userRegister = "user/register";
  static const sendOTP = "user/send-otp";
  static const resetPassword = "user/reset-password";
  static const getProductList = 'product/list-products';
  static const searchProduct = "product/search";
  static const updateAddress = "user/addresses/";
  static const createOrder = 'orders/place';
  static const verifyOrder = 'order/verifyandorder';
  static const orderHistory = 'order/get-orders';
  static const cancelOrder = 'order/cancel-order';
  static const getNearWorkshopList = 'workshop/findNearbyWorkshops';
  static const addToFavourites = 'user/addtofev';
  static const addToCart = 'user/addtocart';
  static const getCartList = 'user/viewcarts';
  static const getFavouriteList = 'user/viewfavorites';
  static const logOut = 'auth/logout';
  static const removeFromCart = 'user/removeFromCart';
  static const removeFromFav = 'user/removefromfev';
  static const bookBreakdownService = 'service/create';
  static const bookWorkshopService = 'service/create';
  static const myAllServices = 'service/get';
  static const updateCartQuantity = 'user/updateCartQuantity';
  static const getHomeData = 'home/home-data';
  static const cancelService = 'service/cancel';
  static const addAddress = 'user/addresses'; // pending
  static const getAllAddresses = 'user/addresses';
  static const getAllUpiId = 'user/upi-ids';
  static const addAllUpiId = 'user/upi-ids';
  static const deleteUpiId = 'user/upi-ids';
  static const createWithdraw = 'withdrawals/request';
  static const withdrawHistory = 'withdrawals/history';
  static const getAllDownLines = 'mlm/downline';
  static const deleteAddress = 'user/addresses/';
  static const fetchUserDetail = "user/user-detail";

}
