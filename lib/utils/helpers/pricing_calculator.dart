
class AppPricingCalculator {
  
    //// Calculate Price based on Tax and shipping
    static double calculateTotalPrice(double productPrice, String location) {
        double taxRate = getTaxRateForLocation(location);
        double taxAmount = productPrice * taxRate;

        double shippingCost = getShippingCost(location);

        double totalPrice = productPrice + taxAmount + shippingCost;
        return totalPrice; 
    }

    static String calculateShippingCost(double productPrice, String location) {
        double shippingCost = getShippingCost(location);
        return shippingCost.toString();
    }

    static String calculateTax(double productPrice, String location) {
       double taxRate = getTaxRateForLocation(location);
       double taxAmount = productPrice * taxRate;
       return taxAmount.toStringAsFixed(4);
    }

    static  double getTaxRateForLocation(String location) {
        if (location == 'Philippines') {
            return 0.12;
        } else if (location == 'Malaysia') {
            return 0.06;
        } else if (location == 'Singapore') {
            return 0.07;
        } else {
            return 0.10;
        }
    }

    static double getShippingCost(String location) {
        if (location == 'Philippines') {
            return 50.00;
        } else if (location == 'Malaysia') {
            return 50.00;
        } else if (location == 'Singapore') {
            return 50.00;
        } else {
            return 50.00;
        }
    }

    // static double calculateCartTotal(CartModel cart) {
    //   return cart.items.map((e) => e.price).fold(0, (previousPrice, currentPrice) => previousPrice + (currentPrice ?? 0));
    // }
}