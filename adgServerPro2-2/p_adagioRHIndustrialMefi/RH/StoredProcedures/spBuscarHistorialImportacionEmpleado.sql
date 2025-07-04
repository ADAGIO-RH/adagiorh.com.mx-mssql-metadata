USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar Historiales Importanción Empleado
** Autor			: Jose Roman
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2019-01-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-05-10			Aneudy Abreu	Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
									Seguridad.tblDetalleFiltrosEmpleadosUsuarios
***************************************************************************************************/
CREATE PROCEDURE [RH].[spBuscarHistorialImportacionEmpleado]
(
	@IDTipoHistorial int =null,
	@dtHistorial [RH].[dtHistorialEmpleado] READONLY,
	@IDUsuario int
)
AS
BEGIN
-- @IDTipoHistorial
	--1	Empresa
	--2	Registro Patronal
	--3	Departamento
	--4	Sucursal
	--5	Centro Costo
	--6	Area
	--7	Region
	--8	Division
	--9	Clasificacion Corporativa

	IF(@IDTipoHistorial = 1)
	BEGIN
	
		SELECT 
		 ROW_NUMBER()OVER(ORDER BY dt.ClaveEmpleado asc) as [IDHistorialEmpleado] 
		,case when exists (SELECT TOP 1 IDEmpleado FROM RH.tblEmpleados where ClaveEmpleado = dt.[ClaveEmpleado]) then (SELECT TOP 1 IDEmpleado FROM RH.tblEmpleados where ClaveEmpleado = dt.[ClaveEmpleado])
			else 0
			end as IDEmpleado
		,dt.[ClaveEmpleado]
		,CASE WHEN EXISTS (SELECT TOP 1 IdEmpresa FROM RH.tblEmpresa where NombreComercial = dt.[Descripcion]) THEN (SELECT TOP 1 IdEmpresa FROM RH.tblEmpresa where NombreComercial = dt.[Descripcion])
			ELSE 0
			END as IDHistorial
		,dt.[Descripcion]
		,dt.[FechaIni]
		,dt.[FechaFin]
		FROM @dtHistorial dt
			inner join RH.tblEmpleadosMaster em on dt.ClaveEmpleado = em.ClaveEmpleado
			inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
		where dt.ClaveEmpleado <> ''
	END ELSE IF(@IDTipoHistorial = 2)
	BEGIN
		
		SELECT 
		 ROW_NUMBER()OVER(ORDER BY  dt.ClaveEmpleado asc) as [IDHistorialEmpleado] 
		,case when exists (SELECT TOP 1 IDEmpleado FROM RH.tblEmpleados where ClaveEmpleado = dt.[ClaveEmpleado]) then (SELECT TOP 1 IDEmpleado FROM RH.tblEmpleados where ClaveEmpleado = dt.[ClaveEmpleado])
			else 0
			end as IDEmpleado
		,dt.[ClaveEmpleado]
		,CASE WHEN EXISTS (SELECT TOP 1 IDRegPatronal FROM RH.tblCatRegPatronal where RazonSocial = dt.[Descripcion]) THEN (SELECT TOP 1 IDRegPatronal FROM RH.tblCatRegPatronal where RazonSocial = dt.[Descripcion])
			ELSE 0
			END as IDHistorial
		,dt.[Descripcion]
		,dt.[FechaIni]
		,dt.[FechaFin]
		FROM @dtHistorial dt
			inner join RH.tblEmpleadosMaster em on dt.ClaveEmpleado = em.ClaveEmpleado
			inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
		where dt.ClaveEmpleado <> ''
	END ELSE IF(@IDTipoHistorial = 3)
	BEGIN
		
		SELECT 
		 ROW_NUMBER()OVER(ORDER BY  dt.ClaveEmpleado asc) as [IDHistorialEmpleado] 
		,case when exists (SELECT TOP 1 IDEmpleado FROM RH.tblEmpleados where ClaveEmpleado = dt.[ClaveEmpleado]) then (SELECT TOP 1 IDEmpleado FROM RH.tblEmpleados where ClaveEmpleado = dt.[ClaveEmpleado])
			else 0
			end as IDEmpleado
		,dt.[ClaveEmpleado]
		,CASE WHEN EXISTS (SELECT TOP 1 IDDepartamento FROM RH.tblCatDepartamentos where Descripcion = dt.[Descripcion]) THEN (SELECT TOP 1 IDDepartamento FROM RH.tblCatDepartamentos where Descripcion = dt.[Descripcion])
			ELSE 0
			END as IDHistorial
		,dt.[Descripcion]
		,dt.[FechaIni]
		,dt.[FechaFin]
		FROM @dtHistorial dt
			inner join RH.tblEmpleadosMaster em on dt.ClaveEmpleado = em.ClaveEmpleado
			inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
		where dt.ClaveEmpleado <> ''
	END ELSE IF(@IDTipoHistorial = 4)
	BEGIN
		
		SELECT 
		 ROW_NUMBER()OVER(ORDER BY  dt.ClaveEmpleado asc) as [IDHistorialEmpleado] 
		,case when exists (SELECT TOP 1 IDEmpleado FROM RH.tblEmpleados where ClaveEmpleado = dt.[ClaveEmpleado]) then (SELECT TOP 1 IDEmpleado FROM RH.tblEmpleados where ClaveEmpleado = dt.[ClaveEmpleado])
			else 0
			end as IDEmpleado
		,dt.[ClaveEmpleado]
		,CASE WHEN EXISTS (SELECT TOP 1 IDSucursal FROM RH.tblCatSucursales where Descripcion = dt.[Descripcion]) THEN (SELECT TOP 1 IDSucursal FROM RH.tblCatSucursales where Descripcion = dt.[Descripcion])
			ELSE 0
			END as IDHistorial
		,dt.[Descripcion]
		,dt.[FechaIni]
		,dt.[FechaFin]
		FROM @dtHistorial dt
			inner join RH.tblEmpleadosMaster em on dt.ClaveEmpleado = em.ClaveEmpleado
			inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
		where dt.ClaveEmpleado <> ''
	END ELSE IF(@IDTipoHistorial = 5)
	BEGIN
		
		SELECT 
		 ROW_NUMBER()OVER(ORDER BY  dt.ClaveEmpleado asc) as [IDHistorialEmpleado] 
		,case when exists (SELECT TOP 1 IDEmpleado FROM RH.tblEmpleados where ClaveEmpleado = dt.[ClaveEmpleado]) then (SELECT TOP 1 IDEmpleado FROM RH.tblEmpleados where ClaveEmpleado = dt.[ClaveEmpleado])
			else 0
			end as IDEmpleado
		,dt.[ClaveEmpleado]
		,CASE WHEN EXISTS (SELECT TOP 1 IDCentroCosto FROM RH.tblCatCentroCosto where Descripcion = dt.[Descripcion]) THEN (SELECT TOP 1 IDCentroCosto FROM RH.tblCatCentroCosto where Descripcion = dt.[Descripcion])
			ELSE 0
			END as IDHistorial
		,dt.[Descripcion]
		,dt.[FechaIni]
		,dt.[FechaFin]
		FROM @dtHistorial dt
			inner join RH.tblEmpleadosMaster em on dt.ClaveEmpleado = em.ClaveEmpleado
			inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
		where dt.ClaveEmpleado <> ''
	END ELSE IF(@IDTipoHistorial = 6)
	BEGIN
		
		SELECT 
		ROW_NUMBER()OVER(ORDER BY  dt.ClaveEmpleado asc) as [IDHistorialEmpleado] 
		,case when exists (SELECT TOP 1 IDEmpleado FROM RH.tblEmpleados where ClaveEmpleado = dt.[ClaveEmpleado]) then (SELECT TOP 1 IDEmpleado FROM RH.tblEmpleados where ClaveEmpleado = dt.[ClaveEmpleado])
			else 0
			end as IDEmpleado
		,dt.[ClaveEmpleado]
		,CASE WHEN EXISTS (SELECT TOP 1 IDArea FROM RH.tblCatArea where JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) = dt.[Descripcion]) THEN (SELECT TOP 1 IDArea FROM RH.tblCatArea where JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) = dt.[Descripcion])
			ELSE 0
			END as IDHistorial
		,dt.[Descripcion]
		,dt.[FechaIni]
		,dt.[FechaFin]
		FROM @dtHistorial dt
			inner join RH.tblEmpleadosMaster em on dt.ClaveEmpleado = em.ClaveEmpleado
			inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
		where dt.ClaveEmpleado <> ''
	END ELSE IF(@IDTipoHistorial = 7)
	BEGIN
		
		SELECT 
		ROW_NUMBER()OVER(ORDER BY  dt.ClaveEmpleado asc) as [IDHistorialEmpleado] 
		,case when exists (SELECT TOP 1 IDEmpleado FROM RH.tblEmpleados where ClaveEmpleado = dt.[ClaveEmpleado]) then (SELECT TOP 1 IDEmpleado FROM RH.tblEmpleados where ClaveEmpleado = dt.[ClaveEmpleado])
			else 0
			end as IDEmpleado
		,dt.[ClaveEmpleado]
		,CASE WHEN EXISTS (SELECT TOP 1 IDRegion FROM RH.tblCatRegiones where Descripcion = dt.[Descripcion]) THEN (SELECT TOP 1 IDRegion FROM RH.tblCatRegiones where Descripcion = dt.[Descripcion])
			ELSE 0
			END as IDHistorial
		,dt.[Descripcion]
		,dt.[FechaIni]
		,dt.[FechaFin]
		FROM @dtHistorial dt
			inner join RH.tblEmpleadosMaster em on dt.ClaveEmpleado = em.ClaveEmpleado
			inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
		where dt.ClaveEmpleado <> ''
	END ELSE IF(@IDTipoHistorial = 8)
	BEGIN
		
		SELECT 
		ROW_NUMBER()OVER(ORDER BY dt.ClaveEmpleado asc) as [IDHistorialEmpleado]  
		,case when exists (SELECT TOP 1 IDEmpleado FROM RH.tblEmpleados where ClaveEmpleado = dt.[ClaveEmpleado]) then (SELECT TOP 1 IDEmpleado FROM RH.tblEmpleados where ClaveEmpleado = dt.[ClaveEmpleado])
			else 0
			end as IDEmpleado
		,dt.[ClaveEmpleado]
		,CASE WHEN EXISTS (SELECT TOP 1 IDDivision FROM RH.tblCatDivisiones where JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) = dt.[Descripcion]) THEN (SELECT TOP 1 IDDivision FROM RH.tblCatDivisiones where Descripcion = dt.[Descripcion])
			ELSE 0
			END as IDHistorial
		,dt.[Descripcion]
		,dt.[FechaIni]
		,dt.[FechaFin]
		FROM @dtHistorial dt
			inner join RH.tblEmpleadosMaster em on dt.ClaveEmpleado = em.ClaveEmpleado
			inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
		where dt.ClaveEmpleado <> ''
	END ELSE IF(@IDTipoHistorial = 9)
	BEGIN
		
		SELECT 
		ROW_NUMBER()OVER(ORDER BY  dt.ClaveEmpleado asc) as [IDHistorialEmpleado] 
		,case when exists (SELECT TOP 1 IDEmpleado FROM RH.tblEmpleados where ClaveEmpleado = dt.[ClaveEmpleado]) then (SELECT TOP 1 IDEmpleado FROM RH.tblEmpleados where ClaveEmpleado = dt.[ClaveEmpleado])
			else 0
			end as IDEmpleado
		,dt.[ClaveEmpleado]
		,CASE WHEN EXISTS (SELECT TOP 1 IDClasificacionCorporativa FROM RH.tblCatClasificacionesCorporativas where Descripcion = dt.[Descripcion]) THEN (SELECT TOP 1 IDClasificacionCorporativa FROM RH.tblCatClasificacionesCorporativas where Descripcion = dt.[Descripcion])
			ELSE 0
			END as IDHistorial
		,dt.[Descripcion]
		,dt.[FechaIni]
		,dt.[FechaFin]
		FROM @dtHistorial dt
			inner join RH.tblEmpleadosMaster em on dt.ClaveEmpleado = em.ClaveEmpleado
			inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
		where dt.ClaveEmpleado <> ''
	END

	
END
GO
