USE [p_adagioRHRHUniversal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jose Vargas
-- Create date: 2022-01-27
-- Description:	Importación a SAP
-- =============================================
CREATE PROCEDURE [SAP].[MX_PersonalInfoImport]
	-- Add the parameters for the stored procedure here	
AS
BEGIN

    -- CAMBIO PARA OBTENER SOLAMENTE LOS CLIENTES DE RUGGEDTECH -- 28 JULIO 2023
    declare @IDClienteRuggedtech  INT  ;
    set @IDClienteRuggedtech =1;

    declare @tempResponse as table (      
        [Descripcion] VARCHAR (100)               ,                                
        [DescripcionIngles] VARCHAR (100)               
    );   
    insert @tempResponse(Descripcion,DescripcionIngles)
    values 
        ('CASADO (A)','Married'),
        ('SOLTERO (A)','Single'),
        ('UNION LIBRE','Free union'),
        ('VIUDO (A)','Widowed')
        
	SELECT 
		isnull(dd.Valor,e.ClaveEmpleado) [person-id-external],
		convert(varchar, e.FechaPrimerIngreso , 101) [start-date],
		'' as  [end-date],
		Utilerias.fnEliminarAcentos(e.Nombre) [first-name],
		Utilerias.fnEliminarAcentos(CONCAT(e.Paterno,' ',e.Materno)) [last-name],
		Utilerias.fnEliminarAcentos(coalesce(e.SegundoNombre,'')) [middle-name],
		'' [salutation],
		'' [suffix],
		case e.Sexo  when  'FEMENINO' then 'F'  when 'MASCULINO' then 'M' Else 'N' end  [gender],
		m.DescripcionIngles [marital-status],
		'Spanish' [native-preferred-lang],
		Utilerias.fnEliminarAcentos(e.Nombre) [preferred-name],
		Utilerias.fnEliminarAcentos(e.NOMBRECOMPLETO) [formal-name],
		'' [Operation]
	FROM RH.tblEmpleadosMaster as e 
        inner join @tempResponse m on m.Descripcion=e.EstadoCivil
        left join rh.tblDatosExtraEmpleados dd on dd.IDEmpleado=e.IDEmpleado and dd.IDDatoExtra=5
    where e.Vigente=1 and e.IDCliente =@IDClienteRuggedtech

END
GO
