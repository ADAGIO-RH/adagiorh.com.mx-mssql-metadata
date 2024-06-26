USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca empleados checador
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
CREATE proc [RH].[spBuscarEmpleadosChecador](  
	@ClaveEmpleado varchar(1000)
	,@IDUsuario int   
)as  
  
--declare   
    --@FechaIni date = '1900-01-01',  
    --@Fechafin date = '9999-12-31',  
    --@empleados [RH].[dtEmpleados]  
    --,@dtFiltros [Nomina].[dtFiltrosRH];  
  
    --insert into @dtFiltros(Catalogo,Value)  
    --select 'NombreClaveFilter',@filter  
  
  --  insert into @empleados  
    --exec [RH].[spBuscarEmpleados]   
    --@IDUsuario=@IDUsuario  
    --,@dtFiltros = @dtFiltros  
  
    select top 1 *  
    from [RH].[tblEmpleadosMaster] e  
		inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario
    where e.ClaveEmpleado = @ClaveEmpleado
GO
