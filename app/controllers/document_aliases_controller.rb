# coding: utf-8

class DocumentAliasesController < ApplicationController

  def new
    @documents = Contactable.find(params[:address_id]).customer.documents_of_others
  end
  def create
    dac = DocaliasContactable.find params[:address_id]
    doc = Document.find_by_id params[:document_id]
    if ! doc # PUT THE VALIDATIONS TO THE MODEL!!!!!!!
      render :template =>'common/alert', :locals => { :message => "Ein Dokument mit der Nr. '#{params[:document_id]}' existiert nicht" }
    elsif doc.customer == dac.customer
      render :template =>'common/alert', :locals => { :message => "'#{doc.doc_name}' gehört zu diesem Kunden" }
    elsif doc.type == 'DocumentAlias'
      render :template =>'common/alert', :locals => { :message => "Dokument Nr. #{params[:document_id]} ist selbst ein Alias!" }
    elsif dac.customer.aliased_documents.include? doc
      render :template =>'common/alert', :locals => { :message => "Es existierts bereits ein Alias auf '#{doc.doc_name}'! (Dokument Nr. #{params[:document_id]})" }
    else
      @document_alias = DocumentAlias.new(:alias_for => params[:document_id], :date => doc.date)
      dac.document_aliases << @document_alias
    end
  end
end
