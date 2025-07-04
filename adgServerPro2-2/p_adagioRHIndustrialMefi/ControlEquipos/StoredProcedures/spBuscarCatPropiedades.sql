USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [ControlEquipos].[spBuscarCatPropiedades](
	@IDTipoArticulo int,
	@IDUsuario int
)
as
begin

	declare @IDIdioma varchar(20);
	SELECT @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	select
		cp.IDPropiedad,
		cp.IDInputType,
		cp.IDTipoArticulo,
		JSON_VALUE(cp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as Nombre,
		cp.Traduccion,
		cp.[Data],
		cp.Orden,
		cit.ConfiguracionSizeInput
	from ControlEquipos.tblCatPropiedades cp
	left join App.tblCatInputsTypes cit
	on cit.IDInputType = cp.IDInputType
	where IDTipoArticulo = @IDTipoArticulo
	order by Orden asc
end

/*
exec [ControlEquipos].[spBuscarCatPropiedades] @IDReferencia = 2


*/


--select * from [ControlEquipos].[tblCatTiposArticulos]
--select * from ControlEquipos.tblCatPropiedades

----select * from App.tblCatInputsTypes
--select * from App.tblCatDatosExtras
--select * from App.tblValoresDatosExtras

--insert into [ControlEquipos].[tblCatTiposArticulos] (Nombre, Descripcion, Codigo, Activo, Etiquetar, PrefijoEtiqueta, LongitudEtiqueta)
--values('Laptop', 'Generico laptop', 'lap', 1, 1, 'adg', 3)

--declare @id int = @@IDENTITY

--insert into [ControlEquipos].[tblCatPropiedades] (IDInputType, TipoReferencia, IDReferencia, Traduccion, [Data], Valor, Activo, IDPropiedadOriginal)
--values ('ListaDesplegable', 0, 2, '{"esmx":{"Nombre":"Marca"},"enus":{"Nombre":"Brand"}}', '[{"ID":"4c5d513a-d2be-4c3f-88ff-9b2fb262ad85","Nombre":"apple"},{"ID":"3ff9efbc-d8ae-4047-807b-e352da8f6aa4","Nombre":"MSI"},{"ID":"18f66a85-f600-445f-9d1a-9f9c9ed2c118","Nombre":"Asus"},{"ID":"de39f34e-32f0-48c4-8483-3a7df25c25e6","Nombre":"Dell"}]', 'de39f34e-32f0-48c4-8483-3a7df25c25e6', 1, 3)

--update [ControlEquipos].[tblCatPropiedades]
--set [Data] = '""'
GO
