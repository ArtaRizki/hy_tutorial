import 'dart:convert';

import 'package:hy_tutorial/common/base/base_controller.dart';
import 'package:hy_tutorial/common/helper/constant.dart';
import 'package:hy_tutorial/src/admin/model/user_list_model.dart';
import 'package:hy_tutorial/src/home/model/home_model.dart';
import 'package:flutter/material.dart';
import 'package:hy_tutorial/src/profile/provider/profile_provider.dart';
import 'package:provider/provider.dart';

class HomeProvider extends BaseController with ChangeNotifier {
  final List<String> staticArray = [
    'Shaft',
    'Upper',
    'Clutch',
    'Turbine',
  ];
  final List<String> staticImage = [
    'assets/icons/admin/ic-shaft.png',
    'assets/icons/admin/ic-upper.png',
    'assets/icons/admin/ic-clutch.png',
    'assets/icons/admin/ic-turbine.png',
  ];



  HomeModel homeModel = HomeModel();
  HomeModel get getHomeModel => this.homeModel;
  set setHomeModel(HomeModel homeModel) => this.homeModel = homeModel;

  getData(BuildContext context) async {
    homeModel = HomeModel();
    userListModel = UserListModel();
    await context.read<ProfileProvider>().fetchProfile(withLoading: false);
    await context.read<HomeProvider>().fetchUserList(withLoading: false);
  }

  Future<void> fetchHome({bool withLoading = false}) async {
    if (withLoading) loading(true);

    final response =
        await post(Constant.BASE_API_FULL + '/dashboard/dashboard/get');

    if (response.statusCode == 201 || response.statusCode == 200) {
      setHomeModel = HomeModel.fromJson(jsonDecode(response.body));
      notifyListeners();

      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["Message"];
      loading(false);
      throw Exception(message);
    }
  }

  UserListModel _userListModel = UserListModel();
  UserListModel get userListModel => this._userListModel;
  set userListModel(UserListModel value) => this._userListModel = value;

  Future<void> fetchUserList({bool withLoading = false}) async {
    if (withLoading) loading(true);
    userListModel = UserListModel();
    Map<String, String> param = {
      'Filter': 'Status',
      'FilterValue': '0',
    };
    final response =
        await get(Constant.BASE_API_FULL + '/admin/users', body: param);

    if (response.statusCode == 201 || response.statusCode == 200) {
      UserListModel model = UserListModel.fromJson(jsonDecode(response.body));
      List<UserListModelData?> newItems = (model.Data ?? [])
          .where((element) => element?.Status != 'active')
          .toList();

      userListModel = model.copyWith(Data: newItems);
      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["Message"];
      loading(false);
      return message;
    }
  }
}
