USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca empleados por Nombre y/o clave Empleado
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-12-24
** Paremetros		:              
	@tipo = 1		: Vigentes
			0		: No Vigentes
			Null	: Ambos

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-05-10			Aneudy Abreu	Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
									Seguridad.tblDetalleFiltrosEmpleadosUsuarios
2020-10-13			Joseph Roman	Se agrega campo de Descripcion de TiposPrestacion 
									Para que cargue la variable en el trabajador en la busqueda rapida.
***************************************************************************************************/
CREATE proc [RH].[spFilterEmpleados](  
	@IDUsuario	int = 0  
	,@filter	varchar(1000)   
	,@tipo		int = null
	,@intranet	bit = 0
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
  
	declare @IDEmpleado int

	select @IDEmpleado = isnull(IDEmpleado,0) from Seguridad.tblUsuarios where IDUsuario = @IDUsuario


	select  e.*
		   ,TP.Descripcion as TiposPrestacion	  
		   ,isnull(tte.IDTipoTrabajador,0)as IDTipoTrabajador
	from [RH].[tblEmpleadosMaster] e with (nolock)
		inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) 
			on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario
		left join RH.tblCatTiposPrestaciones TP with (nolock) 
			on e.IDTipoPrestacion = TP.IDTipoPrestacion
		left join RH.tblTipoTrabajadorEmpleado tte with (nolock) 
			on e.IDEmpleado = tte.IDEmpleado
	where [ClaveNombreCompleto] like '%'+@filter+'%'  
		and (e.Vigente = case when @tipo is not null then @tipo else e.Vigente end)
		and (e.IDEmpleado <> case when @intranet = 1 then @IDEmpleado else 0  end)
	order by ClaveEmpleado asc
GO
