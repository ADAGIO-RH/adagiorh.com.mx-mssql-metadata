USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Valida importación masiva sobre los servicios del empleado
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2024-08-28
** Paremetros		: @dtServiciosEmpleados		Lista de servicios empleado.
					: @IDUsuario			Identificador del usuario.
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE PROCEDURE [ELE].[spValidarImportacionServiciosEmpleado]
( 
	@dtServiciosEmpleados  [ELE].[dtImportacionServiciosEmpleado] READONLY
	, @IDUsuario INT 
)
AS
	BEGIN				
		-- VARIABLES
		DECLARE @IDIdioma VARCHAR(225);
		DECLARE @tempMessages AS TABLE( 
			ID INT
			, [Message] VARCHAR(500)
			, Valid BIT
		)
	
		-- DETECCION DE IDIOMA
		SELECT @IDIdioma = LOWER(REPLACE([APP].[fnGetPreferencia]('Idioma', @IDUsuario, 'esmx'), '-', ''))
				
		-- OBTENEMOS MSJ QUE PERTENECEN A LOS SERVICIOS DEL EMPLEADO
		INSERT @tempMessages(ID, [Message], Valid)
		SELECT [IDMensajeTipo]
				, [Mensaje]
				, [Valid]
        FROM [RH].[tblMensajesMap]
        WHERE [MensajeTipo] = 'ImportacionELEServiciosEmpleadoMap'
        ORDER BY [IDMensajeTipo];

        IF OBJECT_ID('tempdb..#dtImportacionServiciosEmpleado') IS NOT NULL DROP TABLE #dtImportacionServiciosEmpleado
				                                    
		SELECT TD.ClaveEmpleado,
            isnull(ser.IDTipoServicio,0) as IDTipoServicio,
            TD.TipoServicio,
            TD.Catalogo,
            catalogo.IDCatalogo,
            catalogo.DescripcionCatalogo,
            TD.CodigoCatalogo,
            TD.Descripcion,
            TD.Fecha,
            TD.TiempoFecha,
            TD.TiempoDecimal,
            isnull(m.IDEmpleado,0) as IDEmpleado,
            isnull(m.NombreCompleto,'') as NombreCompleto
		INTO #dtImportacionServiciosEmpleado FROM @dtServiciosEmpleados TD	
            left join rh.tblEmpleadosMaster m on td.ClaveEmpleado=m.ClaveEmpleado
            left join ele.tblCatTiposServicios ser on ser.Descripcion=TD.TipoServicio
            left join (                
                select IDArea as IDCatalogo,'Areas' as Catalogo,Codigo as CodigoCatalogo, UPPER (JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))) AS DescripcionCatalogo from rh.tblCatArea with(nolock)
                union all 
                select IDCentroCosto as IDCatalogo,'CentrosCostos' as Catalogo,Codigo as CodigoCatalogo, UPPER (JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))) AS DescripcionCatalogo from rh.tblCatCentroCosto with(nolock)
                union all
                select IDClasificacionCorporativa as IDCatalogo,'ClasificacionesCorporativas' as Catalogo,Codigo as CodigoCatalogo, UPPER (JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))) AS DescripcionCatalogo from rh.tblCatClasificacionesCorporativas with(nolock)
                union all        
                select IDDepartamento as IDCatalogo,'Departamentos' as Catalogo,Codigo as CodigoCatalogo,  UPPER (JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))) AS DescripcionCatalogo from rh.tblCatDepartamentos with(nolock)                
                union all                 
                select IDDivision as IDCatalogo,'Divisiones' as Catalogo,Codigo as CodigoCatalogo, UPPER (JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))) AS DescripcionCatalogo from rh.tblCatDivisiones with(nolock)
                union all
                select IDPuesto as IDCatalogo,'Puestos' as Catalogo,Codigo as CodigoCatalogo, UPPER (JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))) AS DescripcionCatalogo from rh.tblCatPuestos with(nolock)
                union all 
                select IDRegion as IDCatalogo,'Regiones' as Catalogo,Codigo as CodigoCatalogo, UPPER (JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))) AS DescripcionCatalogo from rh.tblCatRegiones with(nolock)        
                union all
                select IDSucursal as IDCatalogo,'Sucursales' as Catalogo,Codigo as CodigoCatalogo, Descripcion AS DescripcionCatalogo from rh.tblCatSucursales with(nolock)	    		        
            ) as catalogo on catalogo.CodigoCatalogo=TD.CodigoCatalogo and catalogo.Catalogo=TD.Catalogo

		
		-- REULTADO FINAL
		SELECT INFO.*,
				-- SUB-CONSULTA QUE OBTIENE MENSAJE
				(SELECT '<b>*</b> ' + M.[Message] AS [Message],
						CAST(M.Valid AS BIT) AS Valid
				FROM @tempMessages M
				WHERE ID IN (SELECT ITEM FROM app.split(INFO.IDMensaje, ',') ) FOR JSON PATH ) AS Msg,
				-- SUB-CONSULTA QUE OBTIENE VALIDACION DEL MENSAJE
				CAST(CASE
						WHEN EXISTS((SELECT M.Valid AS [Message] FROM @tempMessages M WHERE ID IN(SELECT ITEM FROM APP.SPLIT(INFO.IDMensaje, ',')) AND Valid = 0))
							THEN 0
							ELSE 1
					END AS BIT) AS Valid
		FROM (SELECT isnull(D.ClaveEmpleado,'') as ClaveEmpleado
                    ,isnull(D.NombreCompleto,'') as NombreCompleto
                    ,ISNULL(D.IDEmpleado,0) as IDEmpleado
                    ,D.IDTipoServicio
                    ,D.TipoServicio
                    ,isnull(D.Catalogo,'') as Catalogo
                    ,isnull(D.IDCatalogo,0) as IDCatalogo
                    ,isnull(D.DescripcionCatalogo,'')  as DescripcionCatalogo
                    ,D.Descripcion
                    ,D.Fecha
                    ,D.TiempoFecha
                    ,D.TiempoDecimal                    
					 , IDMensaje = IIF(ISNULL(D.TipoServicio, '') <> '', '', '1,') +
                                  IIF(ISNULL(D.IDTipoServicio, 0) <> 0, '', '9,') +
					 			  IIF(ISNULL(D.Catalogo, '') <> '', '', '2,') +
                                  IIF(ISNULL(D.CodigoCatalogo, '') <> '', '', '3,') +
                                  IIF(ISNULL(D.Descripcion, '') <> '', '', '4,') +
                                  IIF(ISNULL(D.ClaveEmpleado, '') <> '', '', '5,') +
                                  IIF(ISNULL(D.IDEmpleado, '') <> '', '', '6,')  +
                                  IIF(ISNULL(D.IDCatalogo, '') <> '', '', '7,') +
                                  IIF(ISNULL(D.Fecha, '') <> '0001-01-01', '', '8,') 					
			  FROM #dtImportacionServiciosEmpleado D) INFO

	END
GO
