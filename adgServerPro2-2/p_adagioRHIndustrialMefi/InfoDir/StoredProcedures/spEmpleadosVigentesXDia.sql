USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Obtiene si el usuario estuvo vigente en un periodo de tiempo
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2022-04-01
** Paremetros		: @Fecha
** IDAzure			: 811

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROC [InfoDir].[spEmpleadosVigentesXDia]
(
	@Fecha DATE	
)
AS
	BEGIN		

		DECLARE @IDUsuarioAdmin INT = 1;

		-- VARIABLES DE TIPO TABLA
		DECLARE @dtEmpleados [RH].[dtEmpleados];
		DECLARE @Fechas [App].[dtFechas];

		-- OBTIENE TODOS LOS EMPLEADOS
		INSERT @dtEmpleados(IDEmpleado)
		SELECT IDEmpleado
		FROM RH.tblEmpleados
		ORDER BY IDEmpleado DESC

		-- OBTIENE LA FECHA EN QUE SE BUSCARA SI EL EMPLEADO ESTA ACTIVO O INACTIVO
		INSERT INTO @Fechas VALUES(@Fecha)

		-- OBTIENE LA VIGENCIA(IDEmpleado, Fecha, Vigente) DE LOS EMPLEADOS EN LA LISTA DE FECHAS SOLICITAS		
		EXEC [RH].[spBuscarListaFechasVigenciaEmpleado] @dtEmpleados = @dtEmpleados, 
														@Fechas = @Fechas,
														@IDUsuario = @IDUsuarioAdmin
	END
GO
