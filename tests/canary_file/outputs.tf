output "file_md5" {
  value = data.azurerm_storage_blob.canary.content_md5
}
