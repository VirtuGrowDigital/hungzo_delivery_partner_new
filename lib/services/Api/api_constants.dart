class ApiConstants {

  // static const baseURL = "http://192.168.1.41:4000/";  // for testing
  static const baseURL = "https://api.hungzo.in/";  // for testing

  // static const baseURL = "http://192.168.1.71:4000/";  // for testing

  // static const baseURL = "https://9fcwsitd51.execute-api.ap-south-1.amazonaws.com/v1/api/"; // production


  static const imageURL = "https://7kn61t4n-3000.inc1.devtunnels.ms/";

  // Api endpoints
  static const accessTokenNew = 'protected/refresh';
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
  static const logOut = 'user/logout';
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