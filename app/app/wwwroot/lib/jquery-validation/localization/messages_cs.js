/*
 * Translated default messages for the jQuery validation plugin.
 * Locale: CS (Czech; čeština, český jazyk)
 */
$.extend( $.validator.messages, {
	required: "Tento údaj je povinný",
	remote: "Opravte tento údaj",
	email: "Zadejte platný e-mail",
	url: "Zadejte platné URL",
	date: "Zadejte platné datum",
	dateISO: "Zadejte platné datum (ISO)",
	number: "Zadejte číslo",
	digits: "Zadávejte pouze číslice",
	creditcard: "Zadejte číslo kreditní karty",
	equalTo: "Zadejte znovu stejnou hodnotu",
	extension: "Zadejte soubor se správnou příponou",
	maxlength: $.validator.format( "Zadejte nejvíce {0} znaků" ),
	minlength: $.validator.format( "Zadejte nejméně {0} znaků" ),
	rangelength: $.validator.format( "Zadejte od {0} do {1} znaků" ),
	range: $.validator.format( "Zadejte hodnotu od {0} do {1}" ),
	max: $.validator.format( "Zadejte hodnotu menší nebo rovnu {0}" ),
	min: $.validator.format( "Zadejte hodnotu větší nebo rovnu {0}" ),
	step: $.validator.format( "Musí být násobkem čísla {0}" )
} );
