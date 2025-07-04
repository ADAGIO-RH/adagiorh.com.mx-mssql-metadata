USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar empleados masivos credencial
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
CREATE PROCEDURE [RH].[spBuscarEmpleadosMasivosCredencial] --20340  
(  
	@Empleados varchar(max)  
	--,@IDUsuario int
)  
AS  
BEGIN  
	SELECT     
		em.IDEmpleado    
		,em.ClaveEmpleado    
		,em.NOMBRECOMPLETO    
		,em.Puesto    
		,em.Departamento    
		,em.Sucursal    
		,em.IMSS  
		,em.RFC  
		,em.CURP  
		,FBE.NombreCompleto NombreEmergencia  
		,ISNULL(FBE.TelefonoCelular,ISNULL(FBE.TelefonoMovil,'')) Telefono  
		,cg.Valor + em.ClaveEmpleado+'.jpg' as Foto  
	FROM rh.tblEmpleadosMaster em    
		--inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
		left join RH.TblFamiliaresBenificiariosEmpleados FBE on FBE.IDEmpleado = EM.IDEmpleado and FBE.Emergencia = 1  
		Cross Apply App.tblConfiguracionesGenerales cg  
	where EM.IDEmpleado in (select ITEM from app.Split(@Empleados,',')) and cg.IDConfiguracion = 'PathFotos'  
END
GO
