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
***************************************************************************************************/
create proc [RH].[spFilterEmpleadosEncargados](  
  @IDUsuario int = 0  
 ,@filter varchar(1000)   
 ,@tipo int = null
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
  
    select *, Email = case 
						when u.Email is not null then u.Email 
						when contac.[Value] is not null then contac.[Value] 
						else '' end  
    from [RH].[tblEmpleadosMaster] e with (nolock)
		inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario
		left join Seguridad.tblUsuarios u on e.IDEmpleado = u.IDEmpleado
		left join (select * 
				   from RH.tblContactoEmpleado ce
						left join RH.tblCatTipoContactoEmpleado ctce on ce.IDTipoContactoEmpleado = ctce.IDTipoContacto AND ctce.Descripcion like '%email%'
		) as contac  on contac.IDEmpleado = e.IDEmpleado
    where [ClaveNombreCompleto] like '%'+@filter+'%'  
		and (e.Vigente = case when @tipo is not null then @tipo else e.Vigente end)
    order by ClaveEmpleado asc


	--select * from RH.tblCatTipoContactoEmpleado
GO
