import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  int _month;

  ///当月工资
  double _monthlyPay,

      ///累计工资
      _monthlyPayTotal,

      ///当月三险一金
      _premium,

      ///累计三险一金
      _premiumTotal,

      ///当月专项扣除
      _deduction,

      ///累计专项扣除
      _deductionTotal,

      ///应缴税额
      _taxPayable,

      ///累计已缴税额
      _taxPayableTotal,

      ///当月应缴税额
      _taxPaid,

      ///税后
      _afterTax;
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController _monthlyPayController;

  TextEditingController _premiumController;

  TextEditingController _deductionController;

  SharedPreferences prefs;

  bool isInitLocalData = false;

  ///初始化
  HomePageState() {
    _initSharedPreferences();
  }

  Future _initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance() as SharedPreferences;
    _monthlyPay = prefs.getDouble("_monthlyPay");
    _monthlyPayTotal = prefs.getDouble("_monthlyPayTotal");
    _premium = prefs.getDouble("_premium");
    _premiumTotal = prefs.getDouble("_premiumTotal");
    _deduction = prefs.getDouble("_deduction");
    _deductionTotal = prefs.getDouble("_deductionTotal");
    _month = prefs.getInt("_month");
    if (_monthlyPay != null) {
      isInitLocalData = true;
      _refresh();
    }
  }

  ///获取纳税期数列表
  List<DropdownMenuItem> _getListData(int position) {
    List<DropdownMenuItem> items = new List();
    for (int i = 1; i < position + 1; i++) {
      DropdownMenuItem dropdownMenuItem1 = new DropdownMenuItem(
        child: new Text('$i'),
        value: i,
      );
      items.add(dropdownMenuItem1);
    }
    return items;
  }

  ///刷新ui
  void _refresh() {
    setState(() {
      if (isInitLocalData) {
        _monthlyPayTotal = _monthlyPay * _month;
        _premiumTotal = _premium * _month;
        _deductionTotal = _deduction * _month;
      } else {
        if (_monthlyPayController.text.length > 0) {
          _monthlyPay = double.parse(_monthlyPayController.text);
          _monthlyPayTotal = _monthlyPay * _month;
        } else {
          _monthlyPay = null;
          _monthlyPayTotal = null;
        }
        if (_premiumController.text.length > 0) {
          _premium = double.parse(_premiumController.text);
          _premiumTotal = _premium * _month;
        } else {
          _premium = null;
          _premiumTotal = null;
        }
        if (_deductionController.text.length > 0) {
          _deduction = double.parse(_deductionController.text);
          _deductionTotal = _deduction * _month;
        } else {
          _deduction = null;
          _deductionTotal = null;
        }
      }
      isInitLocalData = false;
    });
  }

  String _doubleToString(double doubleValue) {
    if (doubleValue == null) {
      return "";
    }
    int intValue = doubleValue.toInt();
    if (doubleValue == intValue) {
      return "$intValue";
    } else {
      return doubleValue.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    _monthlyPayController = TextEditingController.fromValue(TextEditingValue(
        text: _doubleToString(_monthlyPay),
        selection: TextSelection.fromPosition(TextPosition(
            affinity: TextAffinity.downstream,
            offset: _doubleToString(_monthlyPay).length))));
    _premiumController = TextEditingController.fromValue(TextEditingValue(
        text: _doubleToString(_premium),
        selection: TextSelection.fromPosition(TextPosition(
            affinity: TextAffinity.downstream,
            offset: _doubleToString(_premium).length))));
    _deductionController = TextEditingController.fromValue(TextEditingValue(
        text: _doubleToString(_deduction),
        selection: TextSelection.fromPosition(TextPosition(
            affinity: TextAffinity.downstream,
            offset: _doubleToString(_deduction).length))));
    _monthlyPayController.addListener(() {
      _refresh();
    });
    _premiumController.addListener(() {
      _refresh();
    });
    _deductionController.addListener(() {
      _refresh();
    });
    return Scaffold(
      appBar: AppBar(
        title: Text("累进税计算器"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _count,
        child: Text("计算"),
      ),
      body: ListView(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text("当年纳税期数："),
              DropdownButton(
                items: _getListData(12),
                hint: Text("选择当年纳税期数"),
                value: _month,
                onChanged: (val) {
                  _month = val;
                  _refresh();
                },
              )
            ],
          ),
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                _buildTextForm("本月工资", "请输入本月工资", _monthlyPayController,
                    (val) => val == null || val.isEmpty ? "请输入本月工资" : null),
                _buildTextForm(
                    "累计工资",
                    "",
                    TextEditingController.fromValue(TextEditingValue(
                        text: _doubleToString(_monthlyPayTotal),
                        selection: TextSelection.fromPosition(TextPosition(
                            affinity: TextAffinity.downstream,
                            offset:
                                _doubleToString(_monthlyPayTotal).length)))),
                    null),
                _buildTextForm("本月三险一金", "请输入本月三险一金", _premiumController,
                    (val) => val == null || val.isEmpty ? "请输入本月三险一金" : null),
                _buildTextForm(
                    "累计三险一金",
                    "",
                    TextEditingController.fromValue(TextEditingValue(
                        text: _doubleToString(_premiumTotal),
                        selection: TextSelection.fromPosition(TextPosition(
                            affinity: TextAffinity.downstream,
                            offset: _doubleToString(_premiumTotal).length)))),
                    null),
                _buildTextForm("本月专项附加扣除", "请输入本月专项附加扣除", _deductionController,
                    (val) => val == null || val.isEmpty ? "请输入本月专项附加扣除" : null),
                _buildTextForm(
                    "累计专项附加扣除",
                    "",
                    TextEditingController.fromValue(TextEditingValue(
                        text: _doubleToString(_deductionTotal),
                        selection: TextSelection.fromPosition(TextPosition(
                            affinity: TextAffinity.downstream,
                            offset: _doubleToString(_deductionTotal).length)))),
                    null),
                _buildTextForm(
                    "累计应缴税款",
                    "",
                    TextEditingController.fromValue(TextEditingValue(
                        text: _doubleToString(_taxPayableTotal),
                        selection: TextSelection.fromPosition(TextPosition(
                            affinity: TextAffinity.downstream,
                            offset:
                                _doubleToString(_taxPayableTotal).length)))),
                    null),
                _buildTextForm(
                    "累计已缴税款",
                    "",
                    TextEditingController.fromValue(TextEditingValue(
                        text: _doubleToString(_taxPayable),
                        selection: TextSelection.fromPosition(TextPosition(
                            affinity: TextAffinity.downstream,
                            offset: _doubleToString(_taxPayable).length)))),
                    null),
                _buildTextForm(
                    "应缴税款",
                    "",
                    TextEditingController.fromValue(TextEditingValue(
                        text: _doubleToString(_taxPaid),
                        selection: TextSelection.fromPosition(TextPosition(
                            affinity: TextAffinity.downstream,
                            offset: _doubleToString(_taxPaid).length)))),
                    null),
                _buildTextForm(
                    "本月税后收入",
                    "",
                    TextEditingController.fromValue(TextEditingValue(
                        text: _doubleToString(_afterTax),
                        selection: TextSelection.fromPosition(TextPosition(
                            affinity: TextAffinity.downstream,
                            offset: _doubleToString(_afterTax).length)))),
                    null),
              ],
            ),
          )
        ],
      ),
    );
  }

  ///计算
  _count() {
    FocusScope.of(context).requestFocus(FocusNode());
    if (_month == null) {
      Fluttertoast.showToast(
        msg: "请选择当年纳税期数",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
      );
    } else if (_formKey.currentState.validate()) {
      setState(() {
        double taxableIncome =
            _monthlyPayTotal - 5000 * _month - _premiumTotal - _deductionTotal;
        double deductionNumber =
            _getDeductionNumber(_getTaxRate(taxableIncome));
        _taxPayableTotal =
            taxableIncome * _getTaxRate(taxableIncome) - deductionNumber;
        if (_month > 1) {
          double lastMonthTaxableIncome = _monthlyPay * (_month - 1) -
              5000 * (_month - 1) -
              _premium * (_month - 1) -
              _deduction* (_month - 1);
          double lastMonthDeductionNumber =
              _getDeductionNumber(_getTaxRate(lastMonthTaxableIncome));
          _taxPayable =
              lastMonthTaxableIncome * _getTaxRate(lastMonthTaxableIncome) -
                  lastMonthDeductionNumber;
        } else {
          _taxPayable = 0;
        }
        _taxPaid = _taxPayableTotal - _taxPayable;
        _afterTax = _monthlyPay - _taxPaid;
      });

      prefs.setDouble("_monthlyPay", _monthlyPay);
      prefs.setDouble("_monthlyPayTotal", _monthlyPayTotal);
      prefs.setDouble("_premium", _premium);
      prefs.setDouble("_premiumTotal", _premiumTotal);
      prefs.setDouble("_deduction", _deduction);
      prefs.setDouble("_deductionTotal", _deductionTotal);
      prefs.setInt("_month", _month);
      String taxPaid = _taxPaid.toStringAsFixed(2);
      Fluttertoast.showToast(
        msg: "当月应缴税额：$taxPaid元",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
      );
    }
  }

  ///当期税率
  double _getTaxRate(double taxable) {
    if (taxable <= 36000) {
      return 0.03;
    } else if (taxable < 144000) {
      return 0.1;
    } else if (taxable < 300000) {
      return 0.2;
    } else if (taxable < 420000) {
      return 0.25;
    } else if (taxable < 660000) {
      return 0.3;
    } else if (taxable < 960000) {
      return 0.35;
    } else if (taxable < 960000) {
      return 0.45;
    }
    return 0;
  }

  ///当期速算扣除数
  double _getDeductionNumber(double taxRate) {
    if (taxRate == 0.03) {
      return 0;
    } else if (taxRate == 0.1) {
      return 2520;
    } else if (taxRate == 0.2) {
      return 16920;
    } else if (taxRate == 0.25) {
      return 31920;
    } else if (taxRate == 0.3) {
      return 52920;
    } else if (taxRate == 0.35) {
      return 85920;
    } else if (taxRate == 0.45) {
      return 181920;
    }
    return 0;
  }

  ///输入框创建
  TextFormField _buildTextForm(String labelText, String hintText,
      TextEditingController controller, FormFieldSetter<String> validator) {
    return TextFormField(
      controller: controller,
      validator: validator,
      inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: labelText, hintText: hintText),
    );
  }
}
