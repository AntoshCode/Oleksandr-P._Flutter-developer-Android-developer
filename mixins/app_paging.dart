import 'package:adviser/adviser/fca/app/fragments/fragment.dart';
import 'package:adviser/adviser/fca/data/enums/app_status.dart';
import 'package:adviser/adviser/fca/data/helpers/app_print.dart';
import 'package:adviser/adviser/fca/domain/use_cases/app_use_case.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

const _emptyFragmentWarning =
    'Warning: "buildFragment(List<T> items)" was called, but return <empty> fragment.\n'
    'Make sure, what "buildFragment(List<T> items)" method was overridden AND "super.buildFragment(items)" method NOT calling.';

class PagingOutOfRange {
  @override
  String toString() {
    return 'PagingOutOfRange: trying to call addPage(start:true) when previousPage == 0';
  }
}

///Paging [items] data and other states
class PagingState<T> {
  final List<T> items;
  final int prevPage;
  final int nextPage;
  final bool isAllPagesLoading;
  final AppStatus status;
  final String message;

  bool get isPageLoading => status == AppStatus.waiting;

  bool get hasItems => items.isNotEmpty;

  bool get hasNotItems => items.isEmpty;

  PagingState({
    List<T>? items,
    this.isAllPagesLoading = false,
    this.prevPage = 0,
    this.nextPage = 1,
    this.message = '',
    this.status = AppStatus.waiting,
  }) : items = items ?? <T>[];

  PagingState<T> change({
    List<T>? items,
    bool? isAllPagesLoading,
    int? prevPage,
    int? nextPage,
    String? message,
    AppStatus? status,
  }) =>
      PagingState<T>(
        items: items ?? this.items,
        isAllPagesLoading: isAllPagesLoading ?? this.isAllPagesLoading,
        prevPage: prevPage ?? this.prevPage,
        nextPage: nextPage ?? this.nextPage,
        message: message ?? this.message,
        status: status ?? this.status,
      );
}

///Cubit for paging [state] (items and loading status)
class PagingCubit<T> extends Cubit<PagingState<T>> {
  Function(dynamic, [dynamic])? onCubitError;

  PagingCubit([this.onCubitError]) : super(PagingState<T>());

  void _onCubitError(e, [stack]) {
    if (onCubitError != null) {
      onCubitError!(e, stack);
    } else {
      printError(e, stack);
    }
  }

  setError({AppStatus status = AppStatus.unknown, String message = ''}) {
    try {
      emit(state.change(
        message: message,
        status: status,
      ));
    } catch (e, stack) {
      printError(e, stack);
    }
  }

  resetPage() {
    try {
      emit(state.change(
        nextPage: 1,
        prevPage: 0,
        items: <T>[],
        isAllPagesLoading: false,
        status: AppStatus.waiting,
      ));
    } catch (e, stack) {
      _onCubitError(e, stack);
    }
  }

  ///Set new items and set page to [page]
  setPage(List<T> newItems, {int page = 1}) {
    List<T> _items = state.items;
    int _page = page + 1;
    int _startPage = state.prevPage;
    _items.insertAll(0, newItems);
    print(
      'addPageWithPage({prevPage:$_startPage, page:$_page}): $_items',
    );
    try {
      emit(state.change(
        nextPage: _page,
        prevPage: _startPage,
        items: _items,
        status: AppStatus.success,
      ));
    } catch (e, stack) {
      _onCubitError(e, stack);
    }
  }

  ///Add new page to end or start if [start] is true
  addPage(List<T> newItems, {bool start = false}) {
    List<T> _items = state.items;
    int _page = state.nextPage;
    int _startPage = state.prevPage;
    if (newItems.isNotEmpty) {
      if (start) {
        _items.insertAll(0, newItems);
        _startPage--;
      } else {
        _items.addAll(newItems);
        _page++;
      }
    }
    // print(
    //   'addPage({start:$start, startPage:$_startPage, page:$_page}): $_items',
    // );
    if (_startPage < 0) throw PagingOutOfRange();
    try {
      emit(
        state.change(
          nextPage: _page,
          prevPage: _startPage,
          items: _items,
          status: AppStatus.success,
        ),
      );
    } catch (e, stack) {
      _onCubitError(e, stack);
    }
  }

  _startLoading() {
    try {
      emit(state.change(
        status: AppStatus.waiting,
      ));
    } catch (e, stack) {
      _onCubitError(e, stack);
    }
  }

  _allLoaded() {
    try {
      emit(state.change(
        isAllPagesLoading: true,
        status: AppStatus.allPagesDone,
      ));
    } catch (e, stack) {
      _onCubitError(e, stack);
    }
  }
}

///Need to realize the interface for getting page data loading
abstract class PageLoader<T> {
  void loadPage(int page);
}

abstract class PageFragment<T> {
  Fragment buildFragment(List<T> items);
}

///The [PagingDelegate] was implemented to AppPaging and was realized.
///Any presenter delegate can extended from this delegate .
abstract class PagingDelegate<T, E> {
  void onAllPagesLoaded();

  void onPageLoading(int page);

  void onPageLoaded(int page, List<T> data);

  void onPageError(int page, E error);
}

mixin AppPaging<T, E>
    implements PageLoader<T>, PageFragment<T>, PagingDelegate<T, E> {
  ///Paging [paging.items] and status data
  PagingCubit<T> paging = PagingCubit();

  @visibleForOverriding
  Fragment buildFragment(List<T> items) {
    printWarning(_emptyFragmentWarning);
    return Fragment();
  }

  ///Call to starting load pages from first page
  void loadStartPage() {
    paging.resetPage();
    if (paging.state.hasNotItems) loadPage(paging.state.nextPage);
  }

  ///Call to starting with data from [n] page
  void loadStartWithDataAndPage(
      {required List<T> newItems, required int page}) {
    paging.resetPage();
    onPageLoading(page);

    if (paging.state.hasNotItems) paging.setPage(newItems, page: page);
  }

  void loadNext() {
    loadPage(paging.state.nextPage);
  }

  void loadPrev() {
    loadPage(paging.state.prevPage);
  }

  ///Add to ScrollController listener or set to [AppScrollController] to onScroll parameter
  void onPagingScroll(ScrollController scrollController) {
    if (_checkLoadNext(scrollController)) {
      loadNext();
    } else if (_checkLoadPrev(scrollController)) {
      loadPrev();
    }
  }

  ///trigger when change page on [CarouselSlider]
  ///set to [CarouselOptions] to onPageChanged parameter
  void onPagingSwipeLast(indexSlide, allSlide) {
    if (_checkSlideLoadNext(indexSlide, allSlide)) {
      loadNext();
    } else if (_checkSlideLoadPrev(indexSlide)) {
      loadPrev();
    }
  }

  ///PagingDelegate realization
  ///You can @override some of this method, but don't forgot calling [super]
  void onAllPagesLoaded() {
    paging._allLoaded();
  }

  void onPageLoading(int page) {
    paging._startLoading();
  }

  void onPageLoaded(int page, List<T> data) {
    paging.addPage(data);
  }

  void onPageError(int page, E error) {
    if (error is AppCaseError)
      paging.setError(status: error.status, message: error.message);
    else
      paging.setError(message: error.toString());
  }

  ///Calling in scroll controller listener
  bool _checkLoadNext(ScrollController scrollController) {
    return scrollController.offset >=
            scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange &&
        !paging.state.isPageLoading &&
        !paging.state.isAllPagesLoading;
  }

  ///TODO: Create method to load previous page
  bool _checkLoadPrev(ScrollController scrollController) {
    /*scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange &&
        !paging.state.isPageLoading &&
        !paging.state.isAllPagesLoading;*/
    return false;
  }

  ///Calling in swipe slider controller listener
  bool _checkSlideLoadNext(indexSlide, allSlide) {
    printAlert(paging.state.nextPage);
    return indexSlide == allSlide && !paging.state.isAllPagesLoading;
  }

  ///Calling in swipe slider controller listener
  bool _checkSlideLoadPrev(indexSlide) {
    print(paging.state.nextPage);
    return indexSlide == 0 && !paging.state.isAllPagesLoading;
  }
}
