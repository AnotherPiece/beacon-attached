//= require jquery.md5

var createUploader = function(btn, front_key, container, uptoken_url, bucket, callbacks) {
  return Qiniu.uploader({
      runtimes: 'html5,html4',    //上传模式,依次退化
      browse_button: btn,       //上传选择的点选按钮，**必需**
      uptoken_url: uptoken_url,            //Ajax请求upToken的Url，**强烈建议设置**（服务端提供）
      save_key: front_key,
      // flash_swf_url: 'javascripts/Moxie.swf',
      domain: 'http://' + bucket + '.qiniudn.com/',   //bucket 域名，下载资源时用到，**必需**
      container: container,           //上传区域DOM ID，默认是browser_button的父元素，
      max_file_size: '1000mb',           //最大文件体积限制
      max_retries: 3,                   //上传失败最大重试次数
      dragdrop: true,                   //开启可拖曳上传
      drop_element: container,        //拖曳上传区域元素的ID，拖曳文件或文件夹后可触发上传
      chunk_size: '4mb',                //分块上传时，每片的体积
      auto_start: true,                 //选择文件后自动上传，若关闭需要自己绑定事件触发上传,
      init: callbacks
    });
};

$.fn.remoteUploader = function(opt) {
  opt = $.extend({container_id: 'upload-container', front_key: false}, opt);

  var _this = $(this);
  var success_callback = opt.success;

  var attr_name = _this.data('attr');
  var field_name = _this.data('field');
  var orig_hex = _this.data('key');

  var has_hidden_field = field_name !== undefined && attr_name !== undefined;

  var file_size_class = "js-"+attr_name+"-upload-file-size";
  var content_type_class = "js-"+attr_name+"-upload-content-type";
  var file_name_class = "js-"+attr_name+"-upload-file-name";
  var hex_class = "js-"+attr_name+"-upload-hex";
  var updated_at_class = "js-"+attr_name+"-upload-updated-at";

  var file_size = "<input class='" + file_size_class + "' name='"+ field_name +"["+ attr_name +"_file_size]' type='hidden'></input>";
  var content_type = "<input class='" + content_type_class + "' name='"+ field_name +"["+ attr_name +"_content_type]' type='hidden'></input>";
  var file_name = "<input class='" + file_name_class + "' name='"+field_name+"["+ attr_name +"_file_name]' type='hidden'></input>";
  var file_updated_at = "<input class='" + updated_at_class + "' name='"+field_name+"["+ attr_name +"_updated_at]' type='hidden'></input>";
  var hex = "<input class='" + hex_class + "' name='"+field_name+"[hex]' type='hidden'></input>";
  var hidden_field = "<div class='remote-uploader-hidden-fields'>" + hex + file_size + content_type + file_name + file_updated_at + "</div>";

  if (has_hidden_field)
    _this.after(hidden_field);

  createUploader(_this.attr('id'), opt.front_key, opt.container_id, opt.uptoken_url, opt.bucket, {
    'FilesAdded': function(up, files) {
      plupload.each(files, function(file) {
        // 文件添加进队列后,处理相关的事情
        _this.trigger('addFile', [file.name]);
      });
    },
    'UploadProgress': function(up, file) {
      // 每个文件上传时,处理相关的事情
      _this.trigger('uploading', [file.name, file.percent]);
    },
    'FileUploaded': function(up, file, info) {
      var res = $.parseJSON(info);
      var domain = up.getOption('domain');
      var sourceLink = domain + res.key;

      var fileSize = file.size;
      var contentType = file.type;
      var fileName = file.name;
      var hex = res.key.split('/')[3];

      if (has_hidden_field) {
        $('.' + hex_class).val(hex);
        $('.' + file_size_class).val(fileSize);
        $('.' + content_type_class).val(contentType);
        $('.' + file_name_class).val(fileName);
      }

      var datetime = new Date();
      var timeStr = datetime.getFullYear()+"-"+(datetime.getMonth()+1)+"-"+datetime.getDate()+" "+datetime.getHours()+":"+datetime.getMinutes()+":"+datetime.getSeconds();
      $('.' + updated_at_class).val(timeStr);

      var data = {};
      data.fileName = fileName;
      data.hex = hex;
      data.fileSize = fileSize;
      data.contentType = contentType;
      data.key = res.key;
      data.url = sourceLink;

      if (success_callback !== undefined)
        success_callback(data);

      _this.trigger('fileUploaded', [file, info]);
    },
    'UploadComplete': function() {
      //队列文件处理完毕后,处理相关的事情
      _this.trigger('UploadComplete');
    },
    'Key': function(up, file) {
      var nameParts = file.name.split('.')

      var hex = orig_hex;
      if (hex === undefined) {
        hex = MD5(file.name + ":" + $.now() + ":" + Math.random());
      }
      key = hex[0] + "/" + hex[1] + "/" + hex[2] + "/" + hex + "/original." + nameParts[nameParts.length - 1];

      return key;
    }
  });

  return _this;
};
