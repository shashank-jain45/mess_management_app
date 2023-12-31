import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:mess_management_app/domain/core/firestore_failure.dart';
import 'package:mess_management_app/domain/dashboard/i_user_data_facade.dart';
import 'package:mess_management_app/domain/dashboard/user_data_model.dart';
import 'package:mess_management_app/domain/mess_balance/transaction_model.dart';

part 'user_repository_event.dart';
part 'user_repository_state.dart';
part 'user_repository_bloc.freezed.dart';

@injectable
class UserRepositoryBloc
    extends Bloc<UserRepositoryEvent, UserRepositoryState> {
  final IUserDataFacade _dataFacade;
  UserRepositoryBloc(this._dataFacade) : super(UserRepositoryState.intial()) {
    on<UserRepositoryEvent>((event, emit) {
      on<FetchUserData>((event, emit) async {
        return await _fetchUserData(event, emit);
      });
      on<FetchTransactionData>((event, emit) async {
        return await _fetchTransactionDetails(event, emit);
      });
      on<SetUserData>((event, emit) async {
        return await _setUserData(event, emit);
      });
    });
  }
  Future<void> _fetchUserData(
      FetchUserData event, Emitter<UserRepositoryState> emit) async {
    emit(state.copyWith(isFetching: true));
    Either<FirestoreFailure, UserClass> data =
        await _dataFacade.getUserProfile();
    data.fold(
      (l) => emit(
        state.copyWith(
          isFetching: false,
          failureOrSuccess: optionOf(l),
        ),
      ),
      (r) => emit(
        state.copyWith(
          isFetching: false,
          user: r,
        ),
      ),
    );
  }

  Future<void> _fetchTransactionDetails(
      FetchTransactionData event, Emitter<UserRepositoryState> emit) async {
    emit(state.copyWith(isFetching: true));
    Either<FirestoreFailure, List<Transaction>> data =
        await _dataFacade.getUserTransactionHistory();
    data.fold(
      (l) => emit(
        state.copyWith(
          isFetching: false,
          failureOrSuccess: optionOf(l),
        ),
      ),
      (r) => emit(
        state.copyWith(
          isFetching: false,
          transactions: optionOf(r),
        ),
      ),
    );
  }

  Future<void> _setUserData(
      SetUserData event, Emitter<UserRepositoryState> emit) async {
    emit(state.copyWith(isFetching: true));
    Either<FirestoreFailure, Unit> data =
        await _dataFacade.setUserProfile(event.user);
    data.fold(
      (l) => emit(
        state.copyWith(
          isFetching: false,
          failureOrSuccess: optionOf(l),
        ),
      ),
      (r) => emit(
        state.copyWith(
          isFetching: false,
        ),
      ),
    );
  }
}
