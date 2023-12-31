USE [p_adagioRHRoyalCargo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca plazas por Puesto y/o clave plaza
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2021-01-01
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE proc [RH].[spFilterPlazas](  
	@IDUsuario	int = 0  
	,@filter	varchar(1000)   

)as   		
    declare  	   
		@IDIdioma varchar(20);
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	select  
        e.IDPlaza,
        e.Codigo,
        e.IDCliente,
        e.IDPuesto,
        concat(e.Codigo,' - ',JSON_VALUE(p.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))) [NombrePlaza]                    
	from RH.tblCatPlazas e 
        inner join rh.tblCatPuestos p on e.IDPuesto=p.IDPuesto		
	where concat(e.Codigo,' - ',JSON_VALUE(p.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))) like '%'+@filter+'%'  		
	order by NombrePlaza asc
GO
