var Action = function() { }

Action.prototype = {
    
    run: function(parameters) {
        // запускається ДО основного Swift-коду
        
        // parameters.completionFunction повідомляє iOS, що JS завершив попередню обробку. Код у фігурних дужках означає «повернути цей словник даних назад до розширення»
        parameters.completionFunction({"URL": document.URL, "title": document.title });
    },
    
    finalize: function(parameters) {
        // викликається ПІСЛЯ завершення розширення
        
        var customJavaScript = parameters["customJavaScript"];
        // eval виконує JS-код, написаний користувачем, як тільки користувач натискає на кнопку «Готово»
        eval(customJavaScript);
    }
};

var ExtensionPreprocessingJS = new Action


