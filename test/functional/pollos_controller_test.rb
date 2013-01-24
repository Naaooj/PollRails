require 'test_helper'

class PollosControllerTest < ActionController::TestCase
  setup do
    @pollo = pollos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pollos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create pollo" do
    assert_difference('Pollo.count') do
      post :create, :pollo => @pollo.attributes
    end

    assert_redirected_to pollo_path(assigns(:pollo))
  end

  test "should show pollo" do
    get :show, :id => @pollo.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @pollo.to_param
    assert_response :success
  end

  test "should update pollo" do
    put :update, :id => @pollo.to_param, :pollo => @pollo.attributes
    assert_redirected_to pollo_path(assigns(:pollo))
  end

  test "should destroy pollo" do
    assert_difference('Pollo.count', -1) do
      delete :destroy, :id => @pollo.to_param
    end

    assert_redirected_to pollos_path
  end
end
