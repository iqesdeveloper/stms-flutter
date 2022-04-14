class ServerAddressesProd {
  static const serverAddress = 'http://stmsdev.iqes.com.my';
  // 'https://stmstmse.tms.iqes.com.my'; // tmse-stms
  // 'https://stmsent.tms.iqes.com.my'; // ent-stms
  // 'https://stmstms.tms.iqes.com.my'; // tms-stms
  // 'http://stmskj.tms.iqes.com.my'; //production
  // 'http://stmsuat2.iqes.com.my';
  // 'http://stmsuat1.iqes.com.my';
  // 'http://stmsdev.iqes.com.my'; //testing // com.stms.stms
  // https://stmskj.tms.iqes.com.my //com.stms.stmskj

  static const register = '/api/register';
  static const login = '/api/login';
  static const profile = '/api/profile/';
  static const getLocation = '/api/common/getLocation/';
  static const getCustomer = '/api/common/getCustomer/';
  static const getStatus = '/api/common/getStatus/';
  static const getSupplier = '/api/common/getSupplier/';
  static const getInventory = '/api/common/getInventory/';
  static const getReason = '/api/common/getRejectReason/';

  // IN - Purchase order
  static const poDownload = '/api/incoming/purchase_order/';
  static const poItemList = '/api/incoming/purchase_order/list/';
  static const poTransaction =
      '/api/incoming/purchase_order/transactions/create';

  // IN - Project Accounting
  static const paivDownload = '/api/incoming/in_paiv_transfers/';
  static const paivItemList = '/api/incoming/in_paiv_transfers/list/';
  static const paivTransaction =
      '/api/incoming/in_paiv_transfers/transactions/create';

  // IN - Sales Return/ Cancel from customer
  static const srDownload = '/api/incoming/sales_return/';
  static const srItemList = '/api/incoming/sales_return/list/';
  static const srTransaction =
      '/api/incoming/sales_return/transactions/create/';

  // IN - Adjustment Inventory In
  static const aiTransaction = '/api/incoming/inventory_adjustment/create';

  // IN - Item Modification
  static const imTransaction =
      '/api/incoming/item_modification_transaction/create';

  // IN - Customer Return
  static const crList = '/api/incoming/customer_return/';
  static const crItemList = '/api/incoming/customer_return/list/';
  static const crTransaction = '/api/incoming/customer_return/create';

  // IN - Vendor Replacement
  static const vsrList = '/api/incoming/replace_supplier/';
  static const vsrItemList = '/api/incoming/replace_supplier/list/';
  static const vsrTransaction = '/api/incoming/replace_supplier/create';

  // OUT - Sales Invoice
  static const siDownload = '/api/outgoing/sales_invoice/';
  static const siItemList = '/api/outgoing/sales_invoice/list/';
  static const siTransaction =
      '/api/outgoing/sales_invoice/transactions/create/';

  // OUT - Purchase Return
  static const prDownload = '/api/outgoing/purchase_return/';
  static const prItemList = '/api/outgoing/purchase_return/list/';
  static const prTransaction =
      '/api/outgoing/purchase_return/transactions/create/';

  // OUT - PAIV Transfer
  static const paivtDownload = '/api/outgoing/out_paiv_transfers/';
  static const paivtItemList = '/api/outgoing/out_paiv_transfers/list/';
  static const paivtTransaction =
      '/api/outgoing/out_paiv_transfers/transactions/create/';

  // OUT - Adjustment Inventory Out
  static const aoTransaction = '/api/outgoing/inventory_adjustment/create/';

  // OUT - Return to Vendor
  static const rvList = '/api/outgoing/return_supplier/';
  static const rvItemList = '/api/outgoing/return_supplier/list/';
  static const rvTransaction = '/api/outgoing/return_supplier/create';

  // OUT - Repair/Replace Item to Customer
  static const rricList = '/api/outgoing/replace_customer/';
  static const rricItemList = '/api/outgoing/replace_customer/list/';
  static const rricTransaction = '/api/outgoing/replace_customer/create';

  // Transfer In & Out
  static const transferList = '/api/transfer/transfer_in/';
  static const transferItemList = '/api/transfer/transfer_in/list/';
  static const transfer = '/api/transfer/transfer_in/create/';

  // Stock Count
  static const countDownload = '/api/stocks/stock_count/';
  static const countItemList = '/api/stocks/stock_count/list/';
  static const countTransaction =
      '/api/stocks/stock_count/transactions/create/';
}
