require 'test_helper'

class CashBooksControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cash_books)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cash_book" do
    assert_difference('CashBook.count') do
      post :create, :cash_book => { }
    end

    assert_redirected_to cash_book_path(assigns(:cash_book))
  end

  test "should show cash_book" do
    get :show, :id => cash_books(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => cash_books(:one).to_param
    assert_response :success
  end

  test "should update cash_book" do
    put :update, :id => cash_books(:one).to_param, :cash_book => { }
    assert_redirected_to cash_book_path(assigns(:cash_book))
  end

  test "should destroy cash_book" do
    assert_difference('CashBook.count', -1) do
      delete :destroy, :id => cash_books(:one).to_param
    end

    assert_redirected_to cash_books_path
  end
end
