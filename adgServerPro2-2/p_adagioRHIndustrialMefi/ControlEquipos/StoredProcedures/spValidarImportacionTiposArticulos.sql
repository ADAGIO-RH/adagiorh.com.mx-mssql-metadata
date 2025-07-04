USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [ControlEquipos].[spValidarImportacionTiposArticulos](
	@dtTiposArticulos [ControlEquipos].[dtTiposArticulos] readonly,
	@IDUsuario int
)
as
begin
	declare @tempMessages as table(
		ID int,
		[Message] varchar(500),
		Valid bit
	);
	declare @IDIdioma varchar(20)
	SELECT @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	insert @tempMessages(ID, [Message], Valid)
	values
		(1, 'Datos Correctos', 1),
		(2, 'No puedes dejar vacio el campo longitud etiqueta', 0),
		(3, 'La longitud de la etiqueta no puede ser igual o menor a 2, recomendamos una longitud minima mayor o igual a 3', 0),
		(4, 'Debes ingresar el prefijo de la etiqueta', 0),
		(5, 'Este prefijo de etiqueta ya pertenece a otro tipo de articulo', 0),
		(6, 'No puedes dejar vacio el campo Codigo', 0),
		(7, 'Este codigo ya pertenece a otro tipo de articulo', 0),
		(8, 'Es recomendable que el codigo no sean numeros', 1),
		(9, 'Recomendamos un prefijo de etiqueta de al menos 3 caracteres', 0),
		(10, 'Recomendamos que el prefijo de la etiqueta no sean numeros', 1),
		(11, 'No puedes ingresar el mismo código más de una vez', 0),
		(12, 'No puedes ingresar el mismo prefijo de etiqueta más de una vez', 0),
		(13, 'Recomendamos un código de al menos 3 caracteres', 0)


		select
		info.*,
        (SELECT M.[Message] AS [Message],
						CAST(M.Valid AS BIT) AS Valid
				FROM @tempMessages M
				WHERE ID IN (SELECT ITEM FROM app.split(INFO.IDMensaje, ',') ) FOR JSON PATH ) AS Msg,
				-- SUB-CONSULTA QUE OBTIENE VALIDACION DEL MENSAJE
				CAST(CASE
						WHEN EXISTS((SELECT M.Valid AS [Message] FROM @tempMessages M WHERE ID IN(SELECT ITEM FROM APP.SPLIT(INFO.IDMensaje, ',')) AND Valid = 0))
							THEN 0
							ELSE 1
					END AS BIT) AS Valid
	from (
		select 
			ISNULL(TA.Codigo, '') as Codigo,
			ISNULL(UPPER(JSON_VALUE(TA.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre'))), '') as Nombre,
			ISNULL(UPPER(JSON_VALUE(TA.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))), '') as Descripcion,
			ISNULL(TA.PrefijoEtiqueta, '') as PrefijoEtiqueta,
			ISNULL(TA.LongitudEtiqueta, 0) as LongitudEtiqueta,
			ISNULL(TA.Traduccion, '') as Traduccion,
			IDMensaje = 
						case when ISNULL((select top 1 TAA.LongitudEtiqueta from @dtTiposArticulos TAA where TAA.LongitudEtiqueta = TA.LongitudEtiqueta), '') = '' then '2,' else '' end
						+ case when ISNULL((select top 1 TAA.LongitudEtiqueta from @dtTiposArticulos TAA where TAA.LongitudEtiqueta = TA.LongitudEtiqueta), 0) <= 2 then '3,' else '' end
						+ case when ISNULL((select top 1 TAA.PrefijoEtiqueta from @dtTiposArticulos TAA where TAA.PrefijoEtiqueta = TA.PrefijoEtiqueta), '') = '' then '4,' else '' end
						+ case when ISNULL((select top 1 TAA.Codigo from @dtTiposArticulos TAA where TAA.Codigo = TA.Codigo), '') = '' then '6,' else '' end
						+ case when (select top 1 1 from ControlEquipos.tblCatTiposArticulos T where T.Codigo = TA.Codigo) = 1 then '7,' else '' end
						+ case when (select top 1 1 from ControlEquipos.tblCatTiposArticulos T where T.PrefijoEtiqueta = TA.PrefijoEtiqueta) = 1 then '5,' else '' end
						+ case when ISNUMERIC((select top 1 TAA.Codigo from @dtTiposArticulos TAA where TAA.Codigo = TA.Codigo)) = 1 then '8,' else '' end
						+ case when len((select top 1 TAA.PrefijoEtiqueta from @dtTiposArticulos TAA where TAA.PrefijoEtiqueta = TA.PrefijoEtiqueta)) < 3 then '9,' else '' end
						+ case when ISNUMERIC((select top 1 TAA.PrefijoEtiqueta from @dtTiposArticulos TAA where TAA.PrefijoEtiqueta = TA.PrefijoEtiqueta)) = 1 then '10,' else '' end
						+ case when (select count(TAA.Codigo) from @dtTiposArticulos TAA where TAA.Codigo = TA.Codigo) > 1 then '11,' else '' end
						+ case when (select count(TAA.PrefijoEtiqueta) from @dtTiposArticulos TAA where TAA.PrefijoEtiqueta = TA.PrefijoEtiqueta) > 1 then '12,' else '' end
						+ case when len((select top 1 TAA.Codigo from @dtTiposArticulos TAA where TAA.Codigo = TA.Codigo)) < 3 then '13,' else '' end
						+ case when ISNULL((
							select top 1 TAA.Codigo
							from @dtTiposArticulos TAA
							where (TAA.LongitudEtiqueta is not null and TAA.LongitudEtiqueta >=3)
							and (TAA.PrefijoEtiqueta is not null and LEN(TAA.PrefijoEtiqueta) >= 3)
							and (TAA.Codigo is not null and LEN(TAA.Codigo) >= 3)
							and (TAA.Codigo = TA.Codigo)
							and not exists (select top 1 1 from ControlEquipos.tblCatTiposArticulos T where T.Codigo = TA.Codigo)
							and not exists (select top 1 1 from ControlEquipos.tblCatTiposArticulos T where T.PrefijoEtiqueta = TA.PrefijoEtiqueta)
						), '') <> '' then '1,' else '' end
		from @dtTiposArticulos TA
	) info
end

--select * from ControlEquipos.tblCatTiposArticulos

--select ISNUMERIC(null)
GO
