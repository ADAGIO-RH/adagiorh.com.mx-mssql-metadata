USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[TblSubsidioEmpleado](
	[IDSubsidioEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[Subsidio] [bit] NULL,
 CONSTRAINT [PK_NominaTblSubsidioEmpleado_IDSubsidioEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDSubsidioEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_NominaTblSubsidioEmpleado_IDEmpleado] UNIQUE NONCLUSTERED 
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[TblSubsidioEmpleado] ADD  CONSTRAINT [D_NominaTblSubsidioEmpleado_Subsidio]  DEFAULT ((0)) FOR [Subsidio]
GO
ALTER TABLE [Nomina].[TblSubsidioEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpleados_NominaTblSubsidioEmpleado_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Nomina].[TblSubsidioEmpleado] CHECK CONSTRAINT [FK_RHTblEmpleados_NominaTblSubsidioEmpleado_IDEmpleado]
GO
