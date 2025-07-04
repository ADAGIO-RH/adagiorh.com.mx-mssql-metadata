USE [p_adagioRHGrupoEnergy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Validar la clave del empleado.
** Autor			: Julio Castillo
** Email			: jcastillo@adagio.com.mx
** FechaCreacion	: 2025-02-01
** Paremetros		: @ClaveEmpleado varchar(10)

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2025-02-01			Julio Castillo  		Se agrega procedimiento almacenado para validar la clave del empleado.                                      
***************************************************************************************************/
create   procedure [RH].[spValidarClaveEmpleado] --'888905',0,1
(
    @ClaveEmpleado varchar(10),
    @IDCliente int = 0,
    @IDUsuario int
)
as
begin
    select top 1
    Cast(case when count(*) > 0 then 1 else 0 end as bit) as Existe 
    from [RH].[tblEmpleados] 
    where ClaveEmpleado = @ClaveEmpleado
end
GO
