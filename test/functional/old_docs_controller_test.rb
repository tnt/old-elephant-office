require 'test_helper'

class OldDocsControllerTest < ActionController::TestCase
  setup do
    @old_doc = old_docs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:old_docs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create old_doc" do
    assert_difference('OldDoc.count') do
      post :create, old_doc: @old_doc.attributes
    end

    assert_redirected_to old_doc_path(assigns(:old_doc))
  end

  test "should show old_doc" do
    get :show, id: @old_doc.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @old_doc.to_param
    assert_response :success
  end

  test "should update old_doc" do
    put :update, id: @old_doc.to_param, old_doc: @old_doc.attributes
    assert_redirected_to old_doc_path(assigns(:old_doc))
  end

  test "should destroy old_doc" do
    assert_difference('OldDoc.count', -1) do
      delete :destroy, id: @old_doc.to_param
    end

    assert_redirected_to old_docs_path
  end
end
