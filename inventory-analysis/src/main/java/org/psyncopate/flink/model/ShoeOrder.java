package org.psyncopate.flink.model;

import java.util.Date;

public class ShoeOrder {
    private int order_id;
    private String product_id;
    private String customer_id;
    private Date ts;
    
    public int getOrder_id() {
        return order_id;
    }
    public void setOrder_id(int order_id) {
        this.order_id = order_id;
    }
    public String getProduct_id() {
        return product_id;
    }
    public void setProduct_id(String product_id) {
        this.product_id = product_id;
    }
    public String getCustomer_id() {
        return customer_id;
    }
    public void setCustomer_id(String customer_id) {
        this.customer_id = customer_id;
    }
    public Date getTs() {
        return ts;
    }
    public void setTs(Date ts) {
        this.ts = ts;
    }
    @Override
    public String toString() {
        return "ShoeOrder [order_id=" + order_id + ", product_id=" + product_id + ", customer_id=" + customer_id
                + ", ts=" + ts + "]";
    }
    
    
}
