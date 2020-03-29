# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_03_29_133319) do

  create_table "addresses", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", default: 0, null: false, unsigned: true
    t.string "first_name", limit: 100
    t.string "last_name", limit: 100
    t.string "pincode", limit: 15
    t.string "landmark"
    t.text "address"
    t.string "mobile", limit: 15
    t.integer "status", limit: 1, default: 1, comment: "0=>disabled 1=>enabled 2=>default"
    t.string "city"
    t.string "state"
    t.string "country"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["first_name"], name: "index_addresses_on_first_name", type: :fulltext
    t.index ["last_name"], name: "index_addresses_on_last_name", type: :fulltext
  end

  create_table "admin_users", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "first_name", limit: 50
    t.string "last_name", limit: 50
    t.string "email", limit: 50
    t.string "personal_email", limit: 50
    t.string "encrypted_password", limit: 70, default: "", null: false
    t.string "designation", limit: 50
    t.string "department", limit: 50
    t.boolean "enable", default: true
    t.boolean "can_login", default: false
    t.boolean "can_sales_login", default: false
    t.integer "login_attempt", default: 0, unsigned: true
    t.string "mobile", limit: 15, default: ""
    t.string "mobile_other", limit: 15, default: ""
    t.string "reset_password_token", limit: 10
    t.datetime "reset_password_sent_at"
    t.integer "sign_in_count", limit: 1, default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 20
    t.string "last_sign_in_ip", limit: 20
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
  end

  create_table "articles", id: :bigint, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title", limit: 150, null: false
    t.string "description"
    t.string "imageUrl"
    t.string "buttonText", limit: 50
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "carts", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", default: 0, null: false, unsigned: true
    t.integer "product_id", default: 0, unsigned: true
    t.integer "quantity", default: 0, unsigned: true
    t.integer "device_type", default: 0, unsigned: true
    t.index ["device_type"], name: "index_carts_on_device_type"
    t.index ["product_id"], name: "index_carts_on_product_id"
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "devices", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "device_id", limit: 20, null: false
    t.bigint "user_id", unsigned: true
    t.datetime "sign_in_at"
    t.string "registration_id", limit: 500
    t.string "operators", limit: 500
    t.string "model", limit: 50
    t.string "manufacturer", limit: 50
    t.integer "version", default: 0, unsigned: true
    t.boolean "status"
    t.integer "device_type", limit: 1
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["device_id"], name: "index_devices_on_device_id"
    t.index ["device_type"], name: "index_devices_on_device_type"
    t.index ["status"], name: "index_devices_on_status"
    t.index ["user_id"], name: "index_devices_on_user_id"
  end

  create_table "guest_carts", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "token_id", limit: 100
    t.integer "product_id", default: 0, unsigned: true
    t.integer "quantity", default: 0, unsigned: true
    t.integer "device_type", default: 0, unsigned: true
    t.index ["device_type"], name: "index_guest_carts_on_device_type"
    t.index ["product_id"], name: "index_guest_carts_on_product_id"
    t.index ["token_id"], name: "index_guest_carts_on_token_id"
  end

  create_table "order_products", id: :bigint, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "order_id", default: 0, null: false, unsigned: true
    t.integer "product_id", default: 0, unsigned: true
    t.integer "quantity", default: 0, unsigned: true
    t.float "price"
    t.datetime "dispatched_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["order_id"], name: "index_order_products_on_order_id"
    t.index ["product_id"], name: "index_order_products_on_product_id"
  end

  create_table "orders", id: :bigint, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "parent_id", default: 0, null: false, unsigned: true
    t.integer "address_id", unsigned: true
    t.bigint "user_id", default: 0, null: false, unsigned: true
    t.float "cod_money", default: 0.0, null: false
    t.float "shipping_money", default: 0.0, null: false
    t.date "due_date"
    t.integer "device_type", default: 0, unsigned: true
    t.boolean "retailer"
    t.integer "status", unsigned: true
    t.boolean "is_confirm", default: false
    t.datetime "confirm_date"
    t.integer "payment_gateway"
    t.text "packing_note"
    t.integer "admin_user_id", default: 0, unsigned: true
    t.datetime "note_last_updated"
    t.integer "invoice_no", unsigned: true
    t.date "invoice_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["address_id"], name: "index_orders_on_address_id"
    t.index ["device_type"], name: "index_orders_on_device_type"
    t.index ["is_confirm"], name: "index_orders_on_is_confirm"
    t.index ["parent_id"], name: "index_orders_on_parent_id"
    t.index ["retailer", "status", "created_at"], name: "index_orders_on_retailer_and_status_and_created_at"
    t.index ["retailer"], name: "index_orders_on_retailer"
    t.index ["status"], name: "index_orders_on_status"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "products", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "url", limit: 100
    t.string "meta_title"
    t.text "meta_description"
    t.text "meta_keywords"
    t.float "price"
    t.float "mrp"
    t.float "weight"
    t.integer "rank", limit: 2
    t.integer "status", limit: 1, default: 0, comment: "0=>disabled,1=>enabled,2=>Discontinued, 3=>Comming soon"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["status"], name: "index_products_on_status"
    t.index ["url"], name: "index_products_on_url", unique: true
  end

  create_table "users", id: :bigint, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "first_name", limit: 100
    t.string "last_name", limit: 100
    t.integer "gender", limit: 1
    t.integer "status", limit: 1
    t.integer "device_type", limit: 1, default: 0
    t.date "date_of_birth"
    t.decimal "wallet_amount", precision: 12, scale: 3, default: "0.0"
    t.string "facebook_id"
    t.string "google_id"
    t.string "email", limit: 100, default: "", null: false
    t.string "encrypted_password", limit: 70, default: "", null: false
    t.integer "sign_in_count", limit: 1, default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 20
    t.string "last_sign_in_ip", limit: 20
    t.string "mobile", limit: 15
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "is_verified", limit: 1, default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["first_name"], name: "index_users_on_first_name", type: :fulltext
    t.index ["last_name"], name: "index_users_on_last_name", type: :fulltext
    t.index ["status"], name: "index_users_on_status"
  end

end
