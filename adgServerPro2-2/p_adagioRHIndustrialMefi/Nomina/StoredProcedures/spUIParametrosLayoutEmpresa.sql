USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Procedimiento para Crear los valores para los Layouts por Empresa
** Autor			: Jose Roman
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2018--8-27
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROCEDURE Nomina.spUIParametrosLayoutEmpresa --7 ,4
(
	@IDEmpresa int,
	@IDTipoLayout int,
	@IDUsuario int
)
AS
BEGIN
	insert into Nomina.tblEmpresaLayoutsParametros(IDEmpresa,IDLayoutParametro)
	SELECT e.IdEmpresa,p.IDLayoutParametro
		FROM Nomina.tblCatTiposLayout l
			inner join Nomina.tblCatLayoutParametros p
				on L.IDTipoLayout = p.IDTipoLayout
				and l.IDTipoLayout = @IDTipoLayout
			CROSS join RH.tblEmpresa e
			left join Nomina.tblEmpresaLayoutsParametros elp
				on elp.IDEmpresa = @IDEmpresa	
					and elp.IDLayoutParametro = p.IDLayoutParametro
		where e.IdEmpresa = @IDEmpresa
			and elp.IDEmpresaLayoutParametro is null
END
GO
