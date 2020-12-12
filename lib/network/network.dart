class NetworkUrl {
  static String url = "https://andriirwanzahri.000webhostapp.com/restApi";

  static String cover(String gambar) {
    return "https://andriirwanzahri.000webhostapp.com/product/$gambar";
  }

  static String struk(String gambar) {
    return "https://andriirwanzahri.000webhostapp.com/struk/$gambar";
  }

  static String getProduct() {
    return "$url/getproduct.php";
  }

  static String getProductCategory() {
    return "$url/getProductWithCategory.php";
  }

  static String getProductFavoriteWithoutLogin(String deviceInfo) {
    return "$url/getFavoriteWithoutLogin.php?deviceInfo=$deviceInfo";
  }

  static String getOrder(String user) {
    return "$url/getOrder.php?user=$user";
  }

  static String geterjual(String user) {
    return "$url/getProdukBuy.php?user=$user";
  }

  static String uploadStruk() {
    return "$url/uploadStruk.php";
  }

  static String getDataTerakhir(String user) {
    return "$url/dataOrderTerakhir.php?user=$user";
  }

  static String getProdukDetailOrder(String idbeli) {
    return "$url/getDetailOrder.php?idbeli=$idbeli";
  }

  static String getProductCart(String unikID) {
    return "$url/getproductCart.php?unikID=$unikID";
  }

  static String getProdukUser(String id) {
    return "$url/getProdukToko.php?user=$id";
  }

  static String addFavoriteWithoutLogin() {
    return "$url/addFavoriteWithoutLogin.php";
  }

  static String getMetodePembayaran() {
    return "$url/getMetodePembayaran.php";
  }

  static String addCart() {
    return "$url/addCart.php";
  }

  static String verqr() {
    return "$url/verqr.php";
  }

  static String addProduk() {
    return "$url/addproduct.php";
  }

  static String updateProduk() {
    return "$url/updateProduk.php";
  }

  static String updateQuantity() {
    return "$url/updateQuantityCart.php";
  }

  static String getSummaryAmountCart(String unikID) {
    return "$url/getSumAmountCart.php?unikID=$unikID";
  }

  static String getTotalCart(String unikID) {
    return "$url/getTotalCart.php?unikID=$unikID";
  }

  static String addPembelian() {
    return "$url/addPembelian.php";
  }

  static String addPembelianOnly() {
    return "$url/addPembelianOnly.php";
  }

  static String login() {
    return "$url/login.php";
  }

  static String registrasi() {
    return "$url/registrasi.php";
  }
}
