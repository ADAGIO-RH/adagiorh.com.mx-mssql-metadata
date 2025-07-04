USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblDatosExtraEmpleados](
	[IDDatoExtraEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDDatoExtra] [int] NOT NULL,
	[Valor] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEmpleado] [int] NOT NULL,
 CONSTRAINT [PK_tblDatosExtraEmpleados_IDDAtoExtraEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDDatoExtraEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblDatosExtraEmpleados_IDDatoExtra] ON [RH].[tblDatosExtraEmpleados]
(
	[IDDatoExtra] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblDatosExtraEmpleados_IDEmpleado] ON [RH].[tblDatosExtraEmpleados]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblDatosExtraEmpleados]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatDatosExtra_tblDatosExtraEmpleados_IDDatoExtra] FOREIGN KEY([IDDatoExtra])
REFERENCES [RH].[tblCatDatosExtra] ([IDDatoExtra])
GO
ALTER TABLE [RH].[tblDatosExtraEmpleados] CHECK CONSTRAINT [FK_RHTblCatDatosExtra_tblDatosExtraEmpleados_IDDatoExtra]
GO
ALTER TABLE [RH].[tblDatosExtraEmpleados]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpleados_RHTblDatosExtraEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [RH].[tblDatosExtraEmpleados] CHECK CONSTRAINT [FK_RHTblEmpleados_RHTblDatosExtraEmpleados_IDEmpleado]
GO
