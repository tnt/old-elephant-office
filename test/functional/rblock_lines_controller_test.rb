require 'test_helper'

class RblockLinesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:rblock_lines)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_rblock_line
    assert_difference('RblockLine.count') do
      post :create, :rblock_line => { }
    end

    assert_redirected_to rblock_line_path(assigns(:rblock_line))
  end

  def test_should_show_rblock_line
    get :show, :id => rblock_lines(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => rblock_lines(:one).id
    assert_response :success
  end

  def test_should_update_rblock_line
    put :update, :id => rblock_lines(:one).id, :rblock_line => { }
    assert_redirected_to rblock_line_path(assigns(:rblock_line))
  end

  def test_should_destroy_rblock_line
    assert_difference('RblockLine.count', -1) do
      delete :destroy, :id => rblock_lines(:one).id
    end

    assert_redirected_to rblock_lines_path
  end
end
