USE [p_adagioRHSakata]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar columnas face
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-09-14
** Paremetros		: @IDUsuario			- Identificador del usuario.
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

CREATE   PROCEDURE [Staffing].[spBuscarColumnasFace](
	@IDUsuario	  INT = 0	
)
AS
	BEGIN
		
		DECLARE @Activo INT = 1
				, @alias VARCHAR(25) = ''
				, @bold VARCHAR(15) = 'true'
				, @background VARCHAR(15) = '#5d77ff'
				, @textAlign VARCHAR(15) = 'center'
				, @verticalAlign VARCHAR(15) = 'center'
				, @color VARCHAR(15) = 'white'
				, @enable VARCHAR(15) = 'false'				
				, @JsonFiltrosIncidencias VARCHAR(MAX) = N'{ "Filtros":
					[						
						{
							"IDIncidencia": "D",
							"AliasColumna": "D",
							"Orden": 1
						},
						{
							"IDIncidencia": "G",
							"AliasColumna": "PCG",
							"Orden": 2
						},
						{
							"IDIncidencia": "V",
							"AliasColumna": "V",
							"Orden": 3
						},
						{
							"IDIncidencia": "F",
							"AliasColumna": "F",
							"Orden": 4
						},
						{
							"IDIncidencia": "I",
							"AliasColumna": "I",
							"Orden": 5
						},
						{
							"IDIncidencia": "S",
							"AliasColumna": "S",
							"Orden": 6
						},
						{
							"IDIncidencia": "P",
							"AliasColumna": "PSS",
							"Orden": 7
						}						
					]}
					'
				;


		DECLARE @TblColumnas TABLE(
			[value] VARCHAR(25),
			[alias] VARCHAR(25),
			[bold] VARCHAR(15),
			[background] VARCHAR(15),
			[textAlign] VARCHAR(15),
			[verticalAlign] VARCHAR(15),
			[color] VARCHAR(15),
			[enable] VARCHAR(15),
			[order] INT,
			[width] INT
		)

		DECLARE @TblFiltrosIncidencias TABLE(
			[Catalogo] VARCHAR(50),
			[Value] VARCHAR(50),
			[Orden] INT
		)



		INSERT @TblFiltrosIncidencias(Catalogo, [Value], Orden)
		SELECT *
		FROM OPENJSON(JSON_QUERY(@JsonFiltrosIncidencias,  '$.Filtros'))
		  WITH (
			catalogo NVARCHAR(50) '$.IDIncidencia',
			valor NVARCHAR(50) '$.AliasColumna',
			orden INT '$.Orden'	
		  );


		-- COLUMNAS BASE
		INSERT INTO @TblColumnas VALUES('Sucursal', @alias, @bold, @background, @textAlign, @verticalAlign, @color, @enable, -6, 300)
		INSERT INTO @TblColumnas VALUES('Departamento', @alias, @bold, @background, @textAlign, @verticalAlign, @color, @enable, -5, 300)
		INSERT INTO @TblColumnas VALUES('Puesto', @alias, @bold, @background, @textAlign, @verticalAlign, @color, @enable, -4, 300)
		INSERT INTO @TblColumnas VALUES('CantidadStaff', @alias, @bold, @background, @textAlign, @verticalAlign, @color, @enable, -3, 130)
		INSERT INTO @TblColumnas VALUES('CONTRATADO', @alias, @bold, @background, @textAlign, @verticalAlign, @color, @enable, -2, 100)
		INSERT INTO @TblColumnas VALUES('STAFF_PPTO', @alias, @bold, @background, @textAlign, @verticalAlign, @color, @enable, -1, 100)
		INSERT INTO @TblColumnas VALUES('ASISTENCIA', @alias, @bold, @background, @textAlign, @verticalAlign, @color, @enable, 0, 100)
		INSERT INTO @TblColumnas VALUES('AUSENTISMOS', @alias, @bold, @background, @textAlign, @verticalAlign, @color, @enable, 101, 150)
		INSERT INTO @TblColumnas VALUES('PRODUCTIVO_DIA', @alias, @bold, @background, @textAlign, @verticalAlign, @color, @enable, 102, 150)
		INSERT INTO @TblColumnas VALUES('CONTRATADO_VS_STAFF', @alias, @bold, @background, @textAlign, @verticalAlign, @color, @enable, 103, 150)
		INSERT INTO @TblColumnas VALUES('PRODUCTIVO_VS_STAFF', @alias, @bold, @background, @textAlign, @verticalAlign, @color, @enable, 104, 150)
		

		-- COLUMNAS ACTIVAS
		INSERT INTO @TblColumnas ([value], [alias], [bold], [background], [textAlign], [verticalAlign], [color], [enable], [order], [width])
		SELECT FI.Catalogo
				, FI.[Value]
				, @bold
				, @background
				, @textAlign
				, @verticalAlign
				, @color
				, @enable
				, FI.Orden
				, 50
		FROM @TblFiltrosIncidencias FI
		ORDER BY FI.Orden


		-- RESULTADO
		SELECT * FROM @TblColumnas		
		ORDER BY [order]

END
GO
